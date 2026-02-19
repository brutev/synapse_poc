import '../../domain/entities/form_engine_entities.dart';

class FormEngineMetadataModel {
  const FormEngineMetadataModel({required this.tiles});

  final List<TileConfigModel> tiles;

  factory FormEngineMetadataModel.fromJson(Map<String, dynamic> json) {
    return FormEngineMetadataModel(
      tiles: (json['tiles'] as List<dynamic>)
          .map(
            (dynamic item) =>
                TileConfigModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class TileConfigModel {
  const TileConfigModel({
    required this.sectionId,
    required this.title,
    required this.cards,
  });

  final String sectionId;
  final String title;
  final List<CardConfigModel> cards;

  factory TileConfigModel.fromJson(Map<String, dynamic> json) {
    return TileConfigModel(
      sectionId: json['sectionId'] as String,
      title: json['title'] as String,
      cards: (json['cards'] as List<dynamic>)
          .map(
            (dynamic item) =>
                CardConfigModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  TileConfigEntity toEntity() => TileConfigEntity(
    sectionId: sectionId,
    title: title,
    cards: cards.map((CardConfigModel item) => item.toEntity()).toList(),
  );
}

class CardConfigModel {
  const CardConfigModel({
    required this.cardId,
    required this.title,
    required this.fields,
  });

  final String cardId;
  final String title;
  final List<FieldConfigModel> fields;

  factory CardConfigModel.fromJson(Map<String, dynamic> json) {
    return CardConfigModel(
      cardId: json['cardId'] as String,
      title: json['title'] as String,
      fields: (json['fields'] as List<dynamic>)
          .map(
            (dynamic item) =>
                FieldConfigModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  CardConfigEntity toEntity() => CardConfigEntity(
    cardId: cardId,
    title: title,
    fields: fields.map((FieldConfigModel item) => item.toEntity()).toList(),
  );
}

class FieldConfigModel {
  const FieldConfigModel({
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
    this.scenarioOverrides = const <String, FieldScenarioOverrideModel>{},
  });

  final String fieldId;
  final String label;
  final String type;
  final bool mandatory;
  final bool editable;
  final bool visible;
  final Object? defaultValue;
  final List<String> options;
  final ValidationModel? validation;
  final RuleConditionModel? visibleWhen;
  final RuleConditionModel? mandatoryWhen;
  final RuleConditionModel? editableWhen;
  final CalculationModel? calculation;
  final Map<String, FieldScenarioOverrideModel> scenarioOverrides;

  factory FieldConfigModel.fromJson(Map<String, dynamic> json) {
    return FieldConfigModel(
      fieldId: json['fieldId'] as String,
      label: json['label'] as String,
      type: json['type'] as String,
      mandatory: json['mandatory'] as bool? ?? false,
      editable: json['editable'] as bool? ?? true,
      visible: json['visible'] as bool? ?? true,
      defaultValue: json['defaultValue'],
      options: (json['options'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => item.toString())
          .toList(),
      validation: json['validation'] is Map<String, dynamic>
          ? ValidationModel.fromJson(json['validation'] as Map<String, dynamic>)
          : null,
      visibleWhen: json['visibleWhen'] is Map<String, dynamic>
          ? RuleConditionModel.fromJson(
              json['visibleWhen'] as Map<String, dynamic>,
            )
          : null,
      mandatoryWhen: json['mandatoryWhen'] is Map<String, dynamic>
          ? RuleConditionModel.fromJson(
              json['mandatoryWhen'] as Map<String, dynamic>,
            )
          : null,
      editableWhen: json['editableWhen'] is Map<String, dynamic>
          ? RuleConditionModel.fromJson(
              json['editableWhen'] as Map<String, dynamic>,
            )
          : null,
      calculation: json['calculation'] is Map<String, dynamic>
          ? CalculationModel.fromJson(
              json['calculation'] as Map<String, dynamic>,
            )
          : null,
      scenarioOverrides: json['scenarioOverrides'] is Map<String, dynamic>
          ? (json['scenarioOverrides'] as Map<String, dynamic>).map(
              (String key, dynamic value) =>
                  MapEntry<String, FieldScenarioOverrideModel>(
                    key,
                    FieldScenarioOverrideModel.fromJson(
                      value as Map<String, dynamic>,
                    ),
                  ),
            )
          : const <String, FieldScenarioOverrideModel>{},
    );
  }

  FieldConfigEntity toEntity() => FieldConfigEntity(
    fieldId: fieldId,
    label: label,
    type: _toFieldType(type),
    mandatory: mandatory,
    editable: editable,
    visible: visible,
    defaultValue: defaultValue,
    options: options,
    validation: validation?.toEntity(),
    visibleWhen: visibleWhen?.toEntity(),
    mandatoryWhen: mandatoryWhen?.toEntity(),
    editableWhen: editableWhen?.toEntity(),
    calculation: calculation?.toEntity(),
    scenarioOverrides: scenarioOverrides.map(
      (String key, FieldScenarioOverrideModel value) =>
          MapEntry<String, FieldScenarioOverrideEntity>(key, value.toEntity()),
    ),
  );

  DynamicFieldType _toFieldType(String input) {
    switch (input.toUpperCase()) {
      case 'NUMBER':
        return DynamicFieldType.number;
      case 'DATE':
        return DynamicFieldType.date;
      case 'DROPDOWN':
        return DynamicFieldType.dropdown;
      case 'CHECKBOX':
        return DynamicFieldType.checkbox;
      case 'RADIO':
        return DynamicFieldType.radio;
      default:
        return DynamicFieldType.text;
    }
  }
}

class FieldScenarioOverrideModel {
  const FieldScenarioOverrideModel({
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
  final ValidationModel? validation;
  final RuleConditionModel? visibleWhen;
  final RuleConditionModel? mandatoryWhen;
  final RuleConditionModel? editableWhen;

  factory FieldScenarioOverrideModel.fromJson(Map<String, dynamic> json) {
    return FieldScenarioOverrideModel(
      visible: json['visible'] as bool?,
      mandatory: json['mandatory'] as bool?,
      editable: json['editable'] as bool?,
      validation: json['validation'] is Map<String, dynamic>
          ? ValidationModel.fromJson(json['validation'] as Map<String, dynamic>)
          : null,
      visibleWhen: json['visibleWhen'] is Map<String, dynamic>
          ? RuleConditionModel.fromJson(
              json['visibleWhen'] as Map<String, dynamic>,
            )
          : null,
      mandatoryWhen: json['mandatoryWhen'] is Map<String, dynamic>
          ? RuleConditionModel.fromJson(
              json['mandatoryWhen'] as Map<String, dynamic>,
            )
          : null,
      editableWhen: json['editableWhen'] is Map<String, dynamic>
          ? RuleConditionModel.fromJson(
              json['editableWhen'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  FieldScenarioOverrideEntity toEntity() => FieldScenarioOverrideEntity(
    visible: visible,
    mandatory: mandatory,
    editable: editable,
    validation: validation?.toEntity(),
    visibleWhen: visibleWhen?.toEntity(),
    mandatoryWhen: mandatoryWhen?.toEntity(),
    editableWhen: editableWhen?.toEntity(),
  );
}

class ValidationModel {
  const ValidationModel({
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

  factory ValidationModel.fromJson(Map<String, dynamic> json) {
    return ValidationModel(
      regex: json['regex'] as String?,
      min: json['min'] as num?,
      max: json['max'] as num?,
      minLength: json['minLength'] as int?,
      maxLength: json['maxLength'] as int?,
      message: json['message'] as String?,
    );
  }

  ValidationEntity toEntity() => ValidationEntity(
    regex: regex,
    min: min,
    max: max,
    minLength: minLength,
    maxLength: maxLength,
    message: message,
  );
}

class RuleConditionModel {
  const RuleConditionModel({
    required this.fieldId,
    required this.operator,
    this.value,
  });

  final String fieldId;
  final String operator;
  final Object? value;

  factory RuleConditionModel.fromJson(Map<String, dynamic> json) {
    return RuleConditionModel(
      fieldId: json['fieldId'] as String,
      operator: json['operator'] as String,
      value: json['value'],
    );
  }

  RuleConditionEntity toEntity() =>
      RuleConditionEntity(fieldId: fieldId, operator: operator, value: value);
}

class CalculationModel {
  const CalculationModel({
    required this.operation,
    required this.sources,
    this.precision,
  });

  final String operation;
  final List<String> sources;
  final int? precision;

  factory CalculationModel.fromJson(Map<String, dynamic> json) {
    return CalculationModel(
      operation: json['operation'] as String,
      sources: (json['sources'] as List<dynamic>)
          .map((dynamic item) => item.toString())
          .toList(),
      precision: json['precision'] as int?,
    );
  }

  CalculationEntity toEntity() => CalculationEntity(
    operation: operation,
    sources: sources,
    precision: precision,
  );
}
