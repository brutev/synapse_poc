import 'package:equatable/equatable.dart';

import '../../../shared_services/domain/entities/los_entities.dart';

enum StaticFieldType { text, number, date, dropdown, radio, checkbox }

class StaticFieldSchema extends Equatable {
  const StaticFieldSchema({
    required this.fieldId,
    required this.label,
    required this.type,
    this.defaultOptions = const <String>[],
  });

  final String fieldId;
  final String label;
  final StaticFieldType type;
  final List<String> defaultOptions;

  @override
  List<Object?> get props => <Object?>[fieldId, label, type, defaultOptions];
}

class StaticCardSchema extends Equatable {
  const StaticCardSchema({
    required this.cardId,
    required this.title,
    required this.fields,
  });

  final String cardId;
  final String title;
  final List<StaticFieldSchema> fields;

  @override
  List<Object?> get props => <Object?>[cardId, title, fields];
}

class StaticSectionSchema extends Equatable {
  const StaticSectionSchema({
    required this.sectionId,
    required this.title,
    required this.cards,
  });

  final String sectionId;
  final String title;
  final List<StaticCardSchema> cards;

  @override
  List<Object?> get props => <Object?>[sectionId, title, cards];
}

class StaticFieldRuntimeState extends Equatable {
  const StaticFieldRuntimeState({
    required this.visible,
    required this.mandatory,
    required this.editable,
    required this.validation,
    required this.options,
    this.dataSource,
    this.optionVersion,
  });

  final bool visible;
  final bool mandatory;
  final bool editable;
  final Map<String, dynamic> validation;
  final List<String> options;
  final String? dataSource;
  final String? optionVersion;

  @override
  List<Object?> get props => <Object?>[
    visible,
    mandatory,
    editable,
    validation,
    options,
    dataSource,
    optionVersion,
  ];
}

class StaticFormMetrics extends Equatable {
  const StaticFormMetrics({
    this.evaluateMs = 0,
    this.ruleBindingMs = 0,
    this.draftSaveMs = 0,
    this.actionMs = 0,
    this.avgBuildMs = 0,
    this.avgRasterMs = 0,
  });

  final double evaluateMs;
  final double ruleBindingMs;
  final double draftSaveMs;
  final double actionMs;
  final double avgBuildMs;
  final double avgRasterMs;

  StaticFormMetrics copyWith({
    double? evaluateMs,
    double? ruleBindingMs,
    double? draftSaveMs,
    double? actionMs,
    double? avgBuildMs,
    double? avgRasterMs,
  }) {
    return StaticFormMetrics(
      evaluateMs: evaluateMs ?? this.evaluateMs,
      ruleBindingMs: ruleBindingMs ?? this.ruleBindingMs,
      draftSaveMs: draftSaveMs ?? this.draftSaveMs,
      actionMs: actionMs ?? this.actionMs,
      avgBuildMs: avgBuildMs ?? this.avgBuildMs,
      avgRasterMs: avgRasterMs ?? this.avgRasterMs,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    evaluateMs,
    ruleBindingMs,
    draftSaveMs,
    actionMs,
    avgBuildMs,
    avgRasterMs,
  ];
}

class StaticModuleSnapshot extends Equatable {
  const StaticModuleSnapshot({
    required this.schema,
    required this.section,
    required this.values,
    required this.fieldStates,
    required this.actions,
    required this.localBackup,
  });

  final StaticSectionSchema schema;
  final EvaluateSectionEntity section;
  final Map<String, dynamic> values;
  final Map<String, StaticFieldRuntimeState> fieldStates;
  final List<EvaluateActionEntity> actions;
  final Map<String, dynamic> localBackup;

  @override
  List<Object?> get props => <Object?>[
    schema,
    section,
    values,
    fieldStates,
    actions,
    localBackup,
  ];
}
