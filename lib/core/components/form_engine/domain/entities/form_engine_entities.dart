import 'package:equatable/equatable.dart';

enum DynamicFieldType { text, number, date, dropdown, checkbox, radio }

class RuleConditionEntity extends Equatable {
  const RuleConditionEntity({
    required this.fieldId,
    required this.operator,
    required this.value,
  });

  final String fieldId;
  final String operator;
  final Object? value;

  @override
  List<Object?> get props => <Object?>[fieldId, operator, value];
}

class CalculationEntity extends Equatable {
  const CalculationEntity({
    required this.operation,
    required this.sources,
    this.precision,
  });

  final String operation;
  final List<String> sources;
  final int? precision;

  @override
  List<Object?> get props => <Object?>[operation, sources, precision];
}

class ValidationEntity extends Equatable {
  const ValidationEntity({
    this.regex,
    this.min,
    this.max,
    this.minLength,
    this.maxLength,
    this.message,
  });

  final String? regex;
  final num? min;
  final num? max;
  final int? minLength;
  final int? maxLength;
  final String? message;

  @override
  List<Object?> get props => <Object?>[
    regex,
    min,
    max,
    minLength,
    maxLength,
    message,
  ];
}

class FieldConfigEntity extends Equatable {
  const FieldConfigEntity({
    required this.fieldId,
    required this.label,
    required this.type,
    required this.mandatory,
    required this.editable,
    required this.visible,
    this.defaultValue,
    this.options = const <String>[],
    this.validation,
    this.visibleWhen,
    this.mandatoryWhen,
    this.editableWhen,
    this.calculation,
    this.scenarioOverrides = const <String, FieldScenarioOverrideEntity>{},
  });

  final String fieldId;
  final String label;
  final DynamicFieldType type;
  final bool mandatory;
  final bool editable;
  final bool visible;
  final Object? defaultValue;
  final List<String> options;
  final ValidationEntity? validation;
  final RuleConditionEntity? visibleWhen;
  final RuleConditionEntity? mandatoryWhen;
  final RuleConditionEntity? editableWhen;
  final CalculationEntity? calculation;
  final Map<String, FieldScenarioOverrideEntity> scenarioOverrides;

  @override
  List<Object?> get props => <Object?>[
    fieldId,
    label,
    type,
    mandatory,
    editable,
    visible,
    defaultValue,
    options,
    validation,
    visibleWhen,
    mandatoryWhen,
    editableWhen,
    calculation,
    scenarioOverrides,
  ];
}

class FieldScenarioOverrideEntity extends Equatable {
  const FieldScenarioOverrideEntity({
    this.visible,
    this.mandatory,
    this.editable,
    this.validation,
    this.visibleWhen,
    this.mandatoryWhen,
    this.editableWhen,
  });

  final bool? visible;
  final bool? mandatory;
  final bool? editable;
  final ValidationEntity? validation;
  final RuleConditionEntity? visibleWhen;
  final RuleConditionEntity? mandatoryWhen;
  final RuleConditionEntity? editableWhen;

  @override
  List<Object?> get props => <Object?>[
    visible,
    mandatory,
    editable,
    validation,
    visibleWhen,
    mandatoryWhen,
    editableWhen,
  ];
}

class CardConfigEntity extends Equatable {
  const CardConfigEntity({
    required this.cardId,
    required this.title,
    required this.fields,
  });

  final String cardId;
  final String title;
  final List<FieldConfigEntity> fields;

  @override
  List<Object?> get props => <Object?>[cardId, title, fields];
}

class TileConfigEntity extends Equatable {
  const TileConfigEntity({
    required this.sectionId,
    required this.title,
    required this.cards,
  });

  final String sectionId;
  final String title;
  final List<CardConfigEntity> cards;

  @override
  List<Object?> get props => <Object?>[sectionId, title, cards];
}

class FormPerformanceMetrics extends Equatable {
  const FormPerformanceMetrics({
    this.lastRuleEvalMs = 0,
    this.lastSaveMs = 0,
    this.avgBuildMs = 0,
    this.avgRasterMs = 0,
    this.visibleFieldCount = 0,
  });

  final double lastRuleEvalMs;
  final double lastSaveMs;
  final double avgBuildMs;
  final double avgRasterMs;
  final int visibleFieldCount;

  FormPerformanceMetrics copyWith({
    double? lastRuleEvalMs,
    double? lastSaveMs,
    double? avgBuildMs,
    double? avgRasterMs,
    int? visibleFieldCount,
  }) {
    return FormPerformanceMetrics(
      lastRuleEvalMs: lastRuleEvalMs ?? this.lastRuleEvalMs,
      lastSaveMs: lastSaveMs ?? this.lastSaveMs,
      avgBuildMs: avgBuildMs ?? this.avgBuildMs,
      avgRasterMs: avgRasterMs ?? this.avgRasterMs,
      visibleFieldCount: visibleFieldCount ?? this.visibleFieldCount,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    lastRuleEvalMs,
    lastSaveMs,
    avgBuildMs,
    avgRasterMs,
    visibleFieldCount,
  ];
}
