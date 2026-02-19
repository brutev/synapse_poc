import 'package:equatable/equatable.dart';

import '../../domain/entities/form_engine_entities.dart';

enum FormEngineStatus { initial, loading, ready, saving, error }

class FormEngineState extends Equatable {
  const FormEngineState({
    this.status = FormEngineStatus.initial,
    this.tiles = const <TileConfigEntity>[],
    this.activeTile,
    this.scenarioIds = const <String>['BASELINE'],
    this.activeScenarioId = 'BASELINE',
    this.values = const <String, dynamic>{},
    this.visibility = const <String, bool>{},
    this.mandatory = const <String, bool>{},
    this.editable = const <String, bool>{},
    this.errors = const <String, String?>{},
    this.metrics = const FormPerformanceMetrics(),
    this.errorMessage,
  });

  final FormEngineStatus status;
  final List<TileConfigEntity> tiles;
  final TileConfigEntity? activeTile;
  final List<String> scenarioIds;
  final String activeScenarioId;
  final Map<String, dynamic> values;
  final Map<String, bool> visibility;
  final Map<String, bool> mandatory;
  final Map<String, bool> editable;
  final Map<String, String?> errors;
  final FormPerformanceMetrics metrics;
  final String? errorMessage;

  FormEngineState copyWith({
    FormEngineStatus? status,
    List<TileConfigEntity>? tiles,
    TileConfigEntity? activeTile,
    List<String>? scenarioIds,
    String? activeScenarioId,
    Map<String, dynamic>? values,
    Map<String, bool>? visibility,
    Map<String, bool>? mandatory,
    Map<String, bool>? editable,
    Map<String, String?>? errors,
    FormPerformanceMetrics? metrics,
    String? errorMessage,
  }) {
    return FormEngineState(
      status: status ?? this.status,
      tiles: tiles ?? this.tiles,
      activeTile: activeTile ?? this.activeTile,
      scenarioIds: scenarioIds ?? this.scenarioIds,
      activeScenarioId: activeScenarioId ?? this.activeScenarioId,
      values: values ?? this.values,
      visibility: visibility ?? this.visibility,
      mandatory: mandatory ?? this.mandatory,
      editable: editable ?? this.editable,
      errors: errors ?? this.errors,
      metrics: metrics ?? this.metrics,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    tiles,
    activeTile,
    scenarioIds,
    activeScenarioId,
    values,
    visibility,
    mandatory,
    editable,
    errors,
    metrics,
    errorMessage,
  ];
}
