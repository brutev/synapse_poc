import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../constants/static_module_schema.dart';
import '../../../../services/frame_performance_service.dart';
import '../../../../shared_services/domain/entities/los_entities.dart';
import '../../../../shared_services/domain/usecases/evaluate_los_usecase.dart';
import '../../../../shared_services/domain/usecases/execute_los_action_usecase.dart';
import '../../../../shared_services/domain/usecases/save_los_draft_usecase.dart';
import '../../../../shared_services/domain/usecases/submit_los_usecase.dart';
import '../../../form_engine/domain/usecases/load_draft_usecase.dart';
import '../../../form_engine/domain/usecases/save_draft_usecase.dart';
import '../../data/picklist_cache_service.dart';
import '../../domain/draft_conflict_resolver.dart';
import '../../domain/field_state_mapper.dart';
import '../../domain/static_form_models.dart';
import 'static_module_state.dart';

class StaticModuleCubit extends Cubit<StaticModuleState> {
  StaticModuleCubit({
    required EvaluateLosUseCase evaluateUseCase,
    required SaveLosDraftUseCase saveLosDraftUseCase,
    required ExecuteLosActionUseCase executeLosActionUseCase,
    required SubmitLosUseCase submitLosUseCase,
    required LoadDraftUseCase loadDraftUseCase,
    required SaveDraftUseCase saveDraftUseCase,
    required PicklistCacheService picklistCacheService,
    required FramePerformanceService framePerformanceService,
    required DraftConflictResolver draftConflictResolver,
    required FieldStateMapper fieldStateMapper,
  }) : _evaluateUseCase = evaluateUseCase,
       _saveLosDraftUseCase = saveLosDraftUseCase,
       _executeLosActionUseCase = executeLosActionUseCase,
       _submitLosUseCase = submitLosUseCase,
       _loadDraftUseCase = loadDraftUseCase,
       _saveDraftUseCase = saveDraftUseCase,
       _picklistCacheService = picklistCacheService,
       _framePerformanceService = framePerformanceService,
       _draftConflictResolver = draftConflictResolver,
       _fieldStateMapper = fieldStateMapper,
       super(const StaticModuleState()) {
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

  static const String _draftScenarioId = 'BASELINE';

  final EvaluateLosUseCase _evaluateUseCase;
  final SaveLosDraftUseCase _saveLosDraftUseCase;
  final ExecuteLosActionUseCase _executeLosActionUseCase;
  final SubmitLosUseCase _submitLosUseCase;
  final LoadDraftUseCase _loadDraftUseCase;
  final SaveDraftUseCase _saveDraftUseCase;
  final PicklistCacheService _picklistCacheService;
  final FramePerformanceService _framePerformanceService;
  final DraftConflictResolver _draftConflictResolver;
  final FieldStateMapper _fieldStateMapper;

  late final VoidCallback _frameListener;
  Timer? _debounce;
  String? _applicationId;
  String? _sectionId;
  String _phase = 'PRE_SANCTION';
  Map<String, dynamic> _sectionData = const <String, dynamic>{};

  void startMonitoring() => _framePerformanceService.start();
  void stopMonitoring() => _framePerformanceService.stop();

  Future<void> initialize({
    required String applicationId,
    required String sectionId,
    required String phase,
    required Map<String, dynamic> sectionData,
  }) async {
    _applicationId = applicationId;
    _sectionId = sectionId;
    _phase = phase;
    _sectionData = sectionData;

    final StaticSectionSchema? schema = staticModuleSchemas[sectionId];
    if (schema == null) {
      emit(
        state.copyWith(
          status: StaticModuleStatus.error,
          errorMessage: 'Static schema not found for $sectionId',
        ),
      );
      return;
    }

    emit(state.copyWith(status: StaticModuleStatus.loading, clearError: true));

    try {
      final Stopwatch evalSw = Stopwatch()..start();
      final EvaluateResponseEntity evaluate = await _evaluateUseCase(
        applicationId: applicationId,
        phase: phase,
        context: const <String, dynamic>{},
        sectionData: sectionData,
      );
      evalSw.stop();

      final EvaluateSectionEntity section = evaluate.sections.firstWhere(
        (EvaluateSectionEntity item) => item.sectionId == sectionId,
      );

      final Map<String, dynamic> backendValues = <String, dynamic>{
        for (final EvaluateFieldEntity field in section.fields)
          field.fieldId: field.value,
      };
      final Map<String, dynamic> localValues = await _loadDraftUseCase(
        applicationId: applicationId,
        sectionId: sectionId,
        scenarioId: _draftScenarioId,
      );

      final DraftConflictResult merged = _draftConflictResolver.resolve(
        schema: schema,
        backendValues: backendValues,
        localValues: localValues,
      );

      final Stopwatch bindSw = Stopwatch()..start();
      final Map<String, StaticFieldRuntimeState> runtime = _fieldStateMapper
          .map(
            schema: schema,
            evaluateSection: section,
            resolveOptions: (EvaluateFieldEntity field) => _resolveOptions(
              applicationId: applicationId,
              sectionId: sectionId,
              evaluateField: field,
            ),
          );
      bindSw.stop();

      emit(
        state.copyWith(
          status: StaticModuleStatus.ready,
          snapshot: StaticModuleSnapshot(
            schema: schema,
            section: section,
            values: merged.values,
            fieldStates: runtime,
            actions: evaluate.actions,
            localBackup: merged.localBackup,
          ),
          metrics: state.metrics.copyWith(
            evaluateMs: evalSw.elapsedMicroseconds / 1000,
            ruleBindingMs: bindSw.elapsedMicroseconds / 1000,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: StaticModuleStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void onFieldChanged({required String fieldId, required dynamic value}) {
    final StaticModuleSnapshot? snapshot = state.snapshot;
    if (snapshot == null) {
      return;
    }

    final Map<String, dynamic> values = Map<String, dynamic>.from(
      snapshot.values,
    )..[fieldId] = value;

    emit(
      state.copyWith(
        snapshot: StaticModuleSnapshot(
          schema: snapshot.schema,
          section: snapshot.section,
          values: values,
          fieldStates: snapshot.fieldStates,
          actions: snapshot.actions,
          localBackup: snapshot.localBackup,
        ),
      ),
    );
  }

  void saveDraftDebounced({
    required String applicationId,
    required String sectionId,
    Duration delay = const Duration(milliseconds: 350),
  }) {
    _debounce?.cancel();
    _debounce = Timer(delay, () async {
      await saveDraft(applicationId: applicationId, sectionId: sectionId);
    });
  }

  Future<void> saveDraft({
    required String applicationId,
    required String sectionId,
  }) async {
    final StaticModuleSnapshot? snapshot = state.snapshot;
    if (snapshot == null) {
      return;
    }

    emit(state.copyWith(status: StaticModuleStatus.saving));
    final Stopwatch sw = Stopwatch()..start();

    await _saveDraftUseCase(
      applicationId: applicationId,
      sectionId: sectionId,
      scenarioId: _draftScenarioId,
      values: snapshot.values,
    );
    await _saveLosDraftUseCase(
      applicationId: applicationId,
      sectionId: sectionId,
      data: snapshot.values,
    );

    sw.stop();
    emit(
      state.copyWith(
        status: StaticModuleStatus.ready,
        metrics: state.metrics.copyWith(
          draftSaveMs: sw.elapsedMicroseconds / 1000,
        ),
      ),
    );
  }

  Future<void> executeAction({
    required String applicationId,
    required String actionId,
    required Map<String, dynamic> payload,
  }) async {
    final StaticModuleSnapshot? snapshot = state.snapshot;
    if (snapshot == null) {
      return;
    }

    emit(state.copyWith(status: StaticModuleStatus.loading, clearError: true));
    final Stopwatch sw = Stopwatch()..start();
    try {
      await _executeLosActionUseCase(
        applicationId: applicationId,
        actionId: actionId,
        payload: payload,
      );
      sw.stop();

      emit(
        state.copyWith(
          metrics: state.metrics.copyWith(
            actionMs: sw.elapsedMicroseconds / 1000,
          ),
        ),
      );

      final String? initAppId = _applicationId;
      final String? initSectionId = _sectionId;
      if (initAppId != null && initSectionId != null) {
        await initialize(
          applicationId: initAppId,
          sectionId: initSectionId,
          phase: _phase,
          sectionData: _sectionData,
        );
      } else {
        emit(state.copyWith(status: StaticModuleStatus.ready));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: StaticModuleStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<SubmitResponseEntity> submit({required String applicationId}) async {
    emit(
      state.copyWith(status: StaticModuleStatus.submitting, clearError: true),
    );
    try {
      final SubmitResponseEntity response = await _submitLosUseCase(
        applicationId: applicationId,
      );
      emit(state.copyWith(status: StaticModuleStatus.ready));
      return response;
    } catch (e) {
      emit(
        state.copyWith(
          status: StaticModuleStatus.error,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  List<String> _resolveOptions({
    required String applicationId,
    required String sectionId,
    required EvaluateFieldEntity evaluateField,
  }) {
    final List<String> fromEvaluate = evaluateField.options;
    if (fromEvaluate.isNotEmpty) {
      final String version = evaluateField.optionVersion ?? 'default';
      unawaited(
        _picklistCacheService.put(
          applicationId: applicationId,
          sectionId: sectionId,
          fieldId: evaluateField.fieldId,
          optionVersion: version,
          options: fromEvaluate,
        ),
      );
      return fromEvaluate;
    }

    final String version = evaluateField.optionVersion ?? 'default';
    return _picklistCacheService.get(
          applicationId: applicationId,
          sectionId: sectionId,
          fieldId: evaluateField.fieldId,
          optionVersion: version,
        ) ??
        const <String>[];
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _framePerformanceService.notifier.removeListener(_frameListener);
    return super.close();
  }
}
