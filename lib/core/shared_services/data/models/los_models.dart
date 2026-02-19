import '../../domain/entities/los_entities.dart';

class ApplicationCreatedModel {
  const ApplicationCreatedModel({
    required this.applicationId,
    required this.ruleVersion,
  });

  final String applicationId;
  final String ruleVersion;

  factory ApplicationCreatedModel.fromJson(Map<String, dynamic> json) {
    return ApplicationCreatedModel(
      applicationId: json['applicationId'] as String,
      ruleVersion: json['ruleVersion'] as String,
    );
  }

  ApplicationCreatedEntity toEntity() {
    return ApplicationCreatedEntity(
      applicationId: applicationId,
      ruleVersion: ruleVersion,
    );
  }
}

class EvaluateFieldModel {
  const EvaluateFieldModel({
    required this.fieldId,
    required this.type,
    required this.value,
    required this.mandatory,
    required this.editable,
    required this.visible,
    required this.validation,
    required this.options,
    this.dataSource,
    this.optionVersion,
  });

  final String fieldId;
  final String type;
  final dynamic value;
  final bool mandatory;
  final bool editable;
  final bool visible;
  final Map<String, dynamic> validation;
  final List<String> options;
  final String? dataSource;
  final String? optionVersion;

  factory EvaluateFieldModel.fromJson(Map<String, dynamic> json) {
    return EvaluateFieldModel(
      fieldId: json['fieldId'] as String,
      type: json['type'] as String,
      value: json['value'],
      mandatory: json['mandatory'] as bool,
      editable: json['editable'] as bool,
      visible: json['visible'] as bool,
      validation:
          (json['validation'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      options: (json['options'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => item.toString())
          .toList(),
      dataSource: json['dataSource'] as String?,
      optionVersion: json['optionVersion'] as String?,
    );
  }

  EvaluateFieldEntity toEntity() => EvaluateFieldEntity(
    fieldId: fieldId,
    type: type,
    value: value,
    mandatory: mandatory,
    editable: editable,
    visible: visible,
    validation: validation,
    options: options,
    dataSource: dataSource,
    optionVersion: optionVersion,
  );
}

class EvaluateSectionModel {
  const EvaluateSectionModel({
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
  final List<EvaluateFieldModel> fields;

  factory EvaluateSectionModel.fromJson(Map<String, dynamic> json) {
    return EvaluateSectionModel(
      sectionId: json['sectionId'] as String,
      mandatory: json['mandatory'] as bool,
      editable: json['editable'] as bool,
      visible: json['visible'] as bool,
      status: json['status'] as String,
      fields: (json['fields'] as List<dynamic>)
          .map(
            (dynamic item) =>
                EvaluateFieldModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  EvaluateSectionEntity toEntity() => EvaluateSectionEntity(
    sectionId: sectionId,
    mandatory: mandatory,
    editable: editable,
    visible: visible,
    status: status,
    fields: fields.map((EvaluateFieldModel item) => item.toEntity()).toList(),
  );
}

class EvaluateActionModel {
  const EvaluateActionModel({
    required this.actionId,
    required this.triggerField,
  });

  final String actionId;
  final String triggerField;

  factory EvaluateActionModel.fromJson(Map<String, dynamic> json) {
    return EvaluateActionModel(
      actionId: json['actionId'] as String,
      triggerField: json['triggerField'] as String,
    );
  }

  EvaluateActionEntity toEntity() =>
      EvaluateActionEntity(actionId: actionId, triggerField: triggerField);
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
  final List<EvaluateSectionModel> sections;
  final List<EvaluateActionModel> actions;

  factory EvaluateResponseModel.fromJson(Map<String, dynamic> json) {
    return EvaluateResponseModel(
      ruleVersion: json['ruleVersion'] as String,
      applicationId: json['applicationId'] as String,
      phase: json['phase'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map(
            (dynamic item) =>
                EvaluateSectionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      actions: (json['actions'] as List<dynamic>)
          .map(
            (dynamic item) =>
                EvaluateActionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  EvaluateResponseEntity toEntity() => EvaluateResponseEntity(
    ruleVersion: ruleVersion,
    applicationId: applicationId,
    phase: phase,
    sections: sections
        .map((EvaluateSectionModel item) => item.toEntity())
        .toList(),
    actions: actions
        .map((EvaluateActionModel item) => item.toEntity())
        .toList(),
  );
}

class ActionResponseModel {
  const ActionResponseModel({
    required this.success,
    required this.updatedFields,
    required this.fieldLocks,
    required this.message,
  });

  final bool success;
  final Map<String, dynamic> updatedFields;
  final List<String> fieldLocks;
  final String message;

  factory ActionResponseModel.fromJson(Map<String, dynamic> json) {
    return ActionResponseModel(
      success: json['success'] as bool,
      updatedFields:
          (json['updatedFields'] as Map<String, dynamic>? ??
          <String, dynamic>{}),
      fieldLocks: (json['fieldLocks'] as List<dynamic>? ?? <dynamic>[])
          .cast<String>(),
      message: json['message'] as String? ?? '',
    );
  }

  ActionResponseEntity toEntity() => ActionResponseEntity(
    success: success,
    updatedFields: updatedFields,
    fieldLocks: fieldLocks,
    message: message,
  );
}

class SubmitResponseModel {
  const SubmitResponseModel({
    required this.success,
    this.nextPhase,
    this.missingMandatorySections,
  });

  final bool success;
  final String? nextPhase;
  final List<String>? missingMandatorySections;

  factory SubmitResponseModel.fromJson(Map<String, dynamic> json) {
    return SubmitResponseModel(
      success: json['success'] as bool,
      nextPhase: json['nextPhase'] as String?,
      missingMandatorySections:
          (json['missingMandatorySections'] as List<dynamic>?)?.cast<String>(),
    );
  }

  SubmitResponseEntity toEntity() => SubmitResponseEntity(
    success: success,
    nextPhase: nextPhase,
    missingMandatorySections: missingMandatorySections,
  );
}
