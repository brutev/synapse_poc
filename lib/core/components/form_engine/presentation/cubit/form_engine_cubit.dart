import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/frame_performance_service.dart';
import '../../domain/entities/form_engine_entities.dart';
import '../../domain/usecases/load_draft_usecase.dart';
import '../../domain/usecases/load_tiles_usecase.dart';
import '../../domain/usecases/save_draft_usecase.dart';
import 'form_engine_state.dart';

class FormEngineCubit extends Cubit<FormEngineState> {
  FormEngineCubit({
    required LoadTilesUseCase loadTilesUseCase,
    required LoadDraftUseCase loadDraftUseCase,
    required SaveDraftUseCase saveDraftUseCase,
    required FramePerformanceService framePerformanceService,
  }) : _loadTilesUseCase = loadTilesUseCase,
       _loadDraftUseCase = loadDraftUseCase,
       _saveDraftUseCase = saveDraftUseCase,
       _framePerformanceService = framePerformanceService,
       super(const FormEngineState()) {
    _frameListener = () {
      final FramePerformanceSample sample =
          _framePerformanceService.notifier.value;
      emit(
        state.copyWith(
          metrics: state.metrics.copyWith(
            avgBuildMs: sample.avgBuildMs,
            avgRasterMs: sample.avgRasterMs,
          ),
        ),
      );
    };
    _framePerformanceService.notifier.addListener(_frameListener);
  }

  final LoadTilesUseCase _loadTilesUseCase;
  final LoadDraftUseCase _loadDraftUseCase;
  final SaveDraftUseCase _saveDraftUseCase;
  final FramePerformanceService _framePerformanceService;

  late final VoidCallback _frameListener;
  Timer? _debounce;
  static const String _baselineScenarioId = 'BASELINE';

  Future<void> initialize({
    required String applicationId,
    required String sectionId,
  }) async {
    emit(state.copyWith(status: FormEngineStatus.loading, errorMessage: null));

    try {
      final List<TileConfigEntity> tiles = await _loadTilesUseCase();
      final TileConfigEntity active = _resolveTile(tiles, sectionId);
      final List<String> scenarioIds = _extractScenarioIds(tiles);
      final String activeScenarioId = scenarioIds.first;
      final Map<String, dynamic> draft = await _loadDraftUseCase(
        applicationId: applicationId,
        sectionId: active.sectionId,
        scenarioId: activeScenarioId,
      );

      final Map<String, dynamic> initialValues = _buildInitialValues(
        active,
        draft,
      );
      final _DerivedState derived = _evaluate(
        active,
        initialValues,
        scenarioId: activeScenarioId,
      );

      emit(
        state.copyWith(
          status: FormEngineStatus.ready,
          tiles: tiles,
          activeTile: active,
          scenarioIds: scenarioIds,
          activeScenarioId: activeScenarioId,
          values: derived.values,
          visibility: derived.visibility,
          mandatory: derived.mandatory,
          editable: derived.editable,
          errors: derived.errors,
          metrics: state.metrics.copyWith(
            lastRuleEvalMs: derived.ruleMs,
            visibleFieldCount: derived.visibleFieldCount,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [FormEngineCubit] initialize error: $e\n$stackTrace');
      emit(
        state.copyWith(
          status: FormEngineStatus.error,
          errorMessage: 'Failed to load form. Please try again.',
        ),
      );
    }
  }

  void onFieldChanged({required String fieldId, required dynamic value}) {
    final TileConfigEntity? active = state.activeTile;
    if (active == null) {
      return;
    }

    final Map<String, dynamic> nextValues = Map<String, dynamic>.from(
      state.values,
    )..[fieldId] = value;
    final _DerivedState derived = _evaluate(
      active,
      nextValues,
      scenarioId: state.activeScenarioId,
    );

    emit(
      state.copyWith(
        values: derived.values,
        visibility: derived.visibility,
        mandatory: derived.mandatory,
        editable: derived.editable,
        errors: derived.errors,
        metrics: state.metrics.copyWith(
          lastRuleEvalMs: derived.ruleMs,
          visibleFieldCount: derived.visibleFieldCount,
        ),
      ),
    );
  }

  void saveDraftDebounced({
    required String applicationId,
    Duration delay = const Duration(milliseconds: 350),
  }) {
    _debounce?.cancel();
    _debounce = Timer(delay, () async {
      await saveDraft(applicationId: applicationId);
    });
  }

  Future<void> saveDraft({required String applicationId}) async {
    final TileConfigEntity? active = state.activeTile;
    if (active == null) {
      return;
    }

    final Stopwatch sw = Stopwatch()..start();
    emit(state.copyWith(status: FormEngineStatus.saving));

    try {
      await _saveDraftUseCase(
        applicationId: applicationId,
        sectionId: active.sectionId,
        scenarioId: state.activeScenarioId,
        values: state.values,
      );

      sw.stop();
      emit(
        state.copyWith(
          status: FormEngineStatus.ready,
          metrics: state.metrics.copyWith(
            lastSaveMs: sw.elapsedMicroseconds / 1000,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [FormEngineCubit] saveDraft error: $e\n$stackTrace');
      emit(
        state.copyWith(
          status: FormEngineStatus.error,
          errorMessage: 'Failed to save draft. Please try again.',
        ),
      );
    }
  }

  Future<void> switchScenario({
    required String applicationId,
    required String scenarioId,
  }) async {
    final TileConfigEntity? active = state.activeTile;
    if (active == null || scenarioId == state.activeScenarioId) {
      return;
    }

    try {
      emit(state.copyWith(status: FormEngineStatus.loading));
      final Map<String, dynamic> draft = await _loadDraftUseCase(
        applicationId: applicationId,
        sectionId: active.sectionId,
        scenarioId: scenarioId,
      );
      final Map<String, dynamic> values = _buildInitialValues(active, draft);
      final _DerivedState derived = _evaluate(
        active,
        values,
        scenarioId: scenarioId,
      );
      emit(
        state.copyWith(
          status: FormEngineStatus.ready,
          activeScenarioId: scenarioId,
          values: derived.values,
          visibility: derived.visibility,
          mandatory: derived.mandatory,
          editable: derived.editable,
          errors: derived.errors,
          metrics: state.metrics.copyWith(
            lastRuleEvalMs: derived.ruleMs,
            visibleFieldCount: derived.visibleFieldCount,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [FormEngineCubit] switchScenario error: $e\n$stackTrace');
      emit(
        state.copyWith(
          status: FormEngineStatus.error,
          errorMessage: 'Failed to switch scenario. Please try again.',
        ),
      );
    }
  }

  void startMonitoring() => _framePerformanceService.start();
  void stopMonitoring() => _framePerformanceService.stop();

  @override
  Future<void> close() {
    debugPrint('🧹 [FormEngineCubit] Cleaning up resources...');
    // Cancel debounced auto-save
    _debounce?.cancel();
    _debounce = null;
    
    // Remove frame listener
    try {
      _framePerformanceService.notifier.removeListener(_frameListener);
    } catch (e) {
      debugPrint('⚠️  [FormEngineCubit] Error removing frame listener: $e');
    }
    
    // Stop monitoring
    try {
      _framePerformanceService.stop();
    } catch (e) {
      debugPrint('⚠️  [FormEngineCubit] Error stopping monitoring: $e');
    }
    
    return super.close();
  }

  TileConfigEntity _resolveTile(
    List<TileConfigEntity> tiles,
    String sectionId,
  ) {
    for (final TileConfigEntity tile in tiles) {
      if (tile.sectionId == sectionId) {
        return tile;
      }
    }
    return tiles.first;
  }

  Map<String, dynamic> _buildInitialValues(
    TileConfigEntity tile,
    Map<String, dynamic> persisted,
  ) {
    final Map<String, dynamic> values = Map<String, dynamic>.from(persisted);
    for (final CardConfigEntity card in tile.cards) {
      for (final FieldConfigEntity field in card.fields) {
        values.putIfAbsent(field.fieldId, () => field.defaultValue);
      }
    }
    return values;
  }

  _DerivedState _evaluate(
    TileConfigEntity tile,
    Map<String, dynamic> rawValues, {
    required String scenarioId,
  }) {
    final Stopwatch sw = Stopwatch()..start();
    final Map<String, dynamic> values = Map<String, dynamic>.from(rawValues);
    final Map<String, bool> visibility = <String, bool>{};
    final Map<String, bool> mandatory = <String, bool>{};
    final Map<String, bool> editable = <String, bool>{};
    final Map<String, String?> errors = <String, String?>{};

    for (final CardConfigEntity card in tile.cards) {
      for (final FieldConfigEntity field in card.fields) {
        final _ResolvedFieldRules resolved = _resolveRules(field, scenarioId);
        final bool fieldVisible = _isVisible(resolved, values);
        visibility[field.fieldId] = fieldVisible;
        mandatory[field.fieldId] = _isMandatory(resolved, values);
        editable[field.fieldId] = _isEditable(resolved, values);
      }
    }

    for (final CardConfigEntity card in tile.cards) {
      for (final FieldConfigEntity field in card.fields) {
        if (field.calculation != null) {
          values[field.fieldId] = _calculate(field.calculation!, values);
        }
      }
    }

    for (final CardConfigEntity card in tile.cards) {
      for (final FieldConfigEntity field in card.fields) {
        final _ResolvedFieldRules resolved = _resolveRules(field, scenarioId);
        final bool fieldVisible = visibility[field.fieldId] ?? true;
        final bool fieldMandatory =
            mandatory[field.fieldId] ?? resolved.baseMandatory;
        errors[field.fieldId] = _validateField(
          fieldLabel: field.label,
          validation: resolved.validation,
          value: values[field.fieldId],
          visible: fieldVisible,
          mandatory: fieldMandatory,
        );
      }
    }

    sw.stop();

    final int visibleFieldCount = visibility.values.where((bool v) => v).length;
    return _DerivedState(
      values: values,
      visibility: visibility,
      mandatory: mandatory,
      editable: editable,
      errors: errors,
      ruleMs: sw.elapsedMicroseconds / 1000,
      visibleFieldCount: visibleFieldCount,
    );
  }

  bool _isVisible(_ResolvedFieldRules field, Map<String, dynamic> values) {
    if (!field.baseVisible) {
      return false;
    }

    final RuleConditionEntity? condition = field.visibleWhen;
    if (condition == null) {
      return true;
    }

    final dynamic current = values[condition.fieldId];
    switch (condition.operator) {
      case 'equals':
        return current == condition.value;
      case 'notEquals':
        return current != condition.value;
      case 'in':
        return condition.value is List &&
            (condition.value as List).contains(current);
      case 'notEmpty':
        return current != null && current.toString().trim().isNotEmpty;
      default:
        return true;
    }
  }

  bool _isMandatory(_ResolvedFieldRules field, Map<String, dynamic> values) {
    final RuleConditionEntity? condition = field.mandatoryWhen;
    if (condition == null) {
      return field.baseMandatory;
    }
    return _matchCondition(condition, values);
  }

  bool _isEditable(_ResolvedFieldRules field, Map<String, dynamic> values) {
    if (!field.baseEditable) {
      return false;
    }
    final RuleConditionEntity? condition = field.editableWhen;
    if (condition == null) {
      return true;
    }
    return _matchCondition(condition, values);
  }

  bool _matchCondition(
    RuleConditionEntity condition,
    Map<String, dynamic> values,
  ) {
    final dynamic current = values[condition.fieldId];
    switch (condition.operator) {
      case 'equals':
        return current == condition.value;
      case 'notEquals':
        return current != condition.value;
      case 'in':
        return condition.value is List &&
            (condition.value as List).contains(current);
      case 'notEmpty':
        return current != null && current.toString().trim().isNotEmpty;
      default:
        return false;
    }
  }

  dynamic _calculate(
    CalculationEntity calculation,
    Map<String, dynamic> values,
  ) {
    switch (calculation.operation) {
      case 'sum':
        double total = 0;
        for (final String source in calculation.sources) {
          total += _toNum(values[source]);
        }
        return _round(total, calculation.precision);
      case 'subtract':
        if (calculation.sources.isEmpty) {
          return 0;
        }
        double current = _toNum(values[calculation.sources.first]);
        for (final String source in calculation.sources.skip(1)) {
          current -= _toNum(values[source]);
        }
        return _round(current, calculation.precision);
      case 'percent':
        if (calculation.sources.length < 2) {
          return 0;
        }
        final double numerator = _toNum(values[calculation.sources[0]]);
        final double denominator = _toNum(values[calculation.sources[1]]);
        if (denominator == 0) {
          return 0;
        }
        return _round((numerator / denominator) * 100, calculation.precision);
      case 'concat':
        return calculation.sources
            .map((String source) => values[source]?.toString() ?? '')
            .join(' ')
            .trim();
      default:
        return null;
    }
  }

  String? _validateField({
    required String fieldLabel,
    required ValidationEntity? validation,
    dynamic value,
    required bool visible,
    required bool mandatory,
  }) {
    if (!visible) {
      return null;
    }

    if (mandatory && (value == null || value.toString().trim().isEmpty)) {
      return '$fieldLabel is required';
    }

    final ValidationEntity? rule = validation;
    if (rule == null || value == null) {
      return null;
    }

    final String text = value.toString();

    if (rule.minLength != null && text.length < rule.minLength!) {
      return rule.message ??
          '$fieldLabel must be at least ${rule.minLength} characters';
    }
    if (rule.maxLength != null && text.length > rule.maxLength!) {
      return rule.message ??
          '$fieldLabel must be at most ${rule.maxLength} characters';
    }
    if (rule.regex != null && !RegExp(rule.regex!).hasMatch(text)) {
      return rule.message ?? '$fieldLabel format is invalid';
    }

    final num? numericValue = num.tryParse(text);
    if (numericValue != null) {
      if (rule.min != null && numericValue < rule.min!) {
        return rule.message ?? '$fieldLabel must be >= ${rule.min}';
      }
      if (rule.max != null && numericValue > rule.max!) {
        return rule.message ?? '$fieldLabel must be <= ${rule.max}';
      }
    }

    return null;
  }

  double _toNum(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
  }

  dynamic _round(double value, int? precision) {
    if (precision == null) {
      return value;
    }
    return double.parse(value.toStringAsFixed(precision));
  }

  _ResolvedFieldRules _resolveRules(
    FieldConfigEntity field,
    String scenarioId,
  ) {
    final FieldScenarioOverrideEntity? override =
        field.scenarioOverrides[scenarioId];
    return _ResolvedFieldRules(
      baseVisible: override?.visible ?? field.visible,
      baseMandatory: override?.mandatory ?? field.mandatory,
      baseEditable: override?.editable ?? field.editable,
      validation: override?.validation ?? field.validation,
      visibleWhen: override?.visibleWhen ?? field.visibleWhen,
      mandatoryWhen: override?.mandatoryWhen ?? field.mandatoryWhen,
      editableWhen: override?.editableWhen ?? field.editableWhen,
    );
  }

  List<String> _extractScenarioIds(List<TileConfigEntity> tiles) {
    final Set<String> scenarioIds = <String>{_baselineScenarioId};
    for (final TileConfigEntity tile in tiles) {
      for (final CardConfigEntity card in tile.cards) {
        for (final FieldConfigEntity field in card.fields) {
          scenarioIds.addAll(field.scenarioOverrides.keys);
        }
      }
    }
    return scenarioIds.toList()..sort();
  }
}

class _DerivedState {
  const _DerivedState({
    required this.values,
    required this.visibility,
    required this.mandatory,
    required this.editable,
    required this.errors,
    required this.ruleMs,
    required this.visibleFieldCount,
  });

  final Map<String, dynamic> values;
  final Map<String, bool> visibility;
  final Map<String, bool> mandatory;
  final Map<String, bool> editable;
  final Map<String, String?> errors;
  final double ruleMs;
  final int visibleFieldCount;
}

class _ResolvedFieldRules {
  const _ResolvedFieldRules({
    required this.baseVisible,
    required this.baseMandatory,
    required this.baseEditable,
    required this.validation,
    required this.visibleWhen,
    required this.mandatoryWhen,
    required this.editableWhen,
  });

  final bool baseVisible;
  final bool baseMandatory;
  final bool baseEditable;
  final ValidationEntity? validation;
  final RuleConditionEntity? visibleWhen;
  final RuleConditionEntity? mandatoryWhen;
  final RuleConditionEntity? editableWhen;
}
