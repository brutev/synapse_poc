import '../../domain/entities/action_entity.dart';
import '../../domain/entities/evaluate_response_entity.dart';
import '../../domain/entities/field_entity.dart';
import '../../domain/entities/section_entity.dart';

class FieldModel {
  const FieldModel({
    required this.fieldId,
    required this.type,
    required this.value,
    required this.mandatory,
    required this.editable,
    required this.visible,
    required this.validation,
  });

  final String fieldId;
  final String type;
  final Object? value;
  final bool mandatory;
  final bool editable;
  final bool visible;
  final Map<String, dynamic> validation;

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      fieldId: json['fieldId'] as String,
      type: json['type'] as String,
      value: json['value'],
      mandatory: json['mandatory'] as bool,
      editable: json['editable'] as bool,
      visible: json['visible'] as bool,
      validation: (json['validation'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fieldId': fieldId,
      'type': type,
      'value': value,
      'mandatory': mandatory,
      'editable': editable,
      'visible': visible,
      'validation': validation,
    };
  }

  FieldEntity toEntity() => FieldEntity(
        fieldId: fieldId,
        type: type,
        value: value,
        mandatory: mandatory,
        editable: editable,
        visible: visible,
        validation: validation,
      );
}

class SectionModel {
  const SectionModel({
    required this.sectionId,
    required this.mandatory,
    required this.editable,
    required this.visible,
    required this.status,
    required this.fields,
  });

  final String sectionId;
  final bool mandatory;
  final bool editable;
  final bool visible;
  final String status;
  final List<FieldModel> fields;

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      sectionId: json['sectionId'] as String,
      mandatory: json['mandatory'] as bool,
      editable: json['editable'] as bool,
      visible: json['visible'] as bool,
      status: json['status'] as String,
      fields: (json['fields'] as List<dynamic>)
          .map(
            (dynamic item) => FieldModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sectionId': sectionId,
      'mandatory': mandatory,
      'editable': editable,
      'visible': visible,
      'status': status,
      'fields': fields.map((FieldModel field) => field.toJson()).toList(),
    };
  }

  SectionEntity toEntity() => SectionEntity(
        sectionId: sectionId,
        mandatory: mandatory,
        editable: editable,
        visible: visible,
        status: status,
        fields: fields.map((FieldModel field) => field.toEntity()).toList(),
      );
}

class ActionModel {
  const ActionModel({required this.actionId, required this.triggerField});

  final String actionId;
  final String triggerField;

  factory ActionModel.fromJson(Map<String, dynamic> json) {
    return ActionModel(
      actionId: json['actionId'] as String,
      triggerField: json['triggerField'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'actionId': actionId,
      'triggerField': triggerField,
    };
  }

  ActionEntity toEntity() =>
      ActionEntity(actionId: actionId, triggerField: triggerField);
}

class EvaluateResponseModel {
  const EvaluateResponseModel({
    required this.ruleVersion,
    required this.applicationId,
    required this.phase,
    required this.sections,
    required this.actions,
  });

  final String ruleVersion;
  final String applicationId;
  final String phase;
  final List<SectionModel> sections;
  final List<ActionModel> actions;

  factory EvaluateResponseModel.fromJson(Map<String, dynamic> json) {
    return EvaluateResponseModel(
      ruleVersion: json['ruleVersion'] as String,
      applicationId: json['applicationId'] as String,
      phase: json['phase'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map(
            (dynamic item) =>
                SectionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      actions: (json['actions'] as List<dynamic>)
          .map(
            (dynamic item) =>
                ActionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'ruleVersion': ruleVersion,
      'applicationId': applicationId,
      'phase': phase,
      'sections':
          sections.map((SectionModel section) => section.toJson()).toList(),
      'actions': actions.map((ActionModel action) => action.toJson()).toList(),
    };
  }

  EvaluateResponseEntity toEntity() {
    return EvaluateResponseEntity(
      ruleVersion: ruleVersion,
      applicationId: applicationId,
      phase: phase,
      sections:
          sections.map((SectionModel section) => section.toEntity()).toList(),
      actions: actions.map((ActionModel action) => action.toEntity()).toList(),
    );
  }
}
