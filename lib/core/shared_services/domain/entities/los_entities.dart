import 'package:equatable/equatable.dart';

class ApplicationCreatedEntity extends Equatable {
  const ApplicationCreatedEntity({
    required this.applicationId,
    required this.ruleVersion,
  });

  final String applicationId;
  final String ruleVersion;

  @override
  List<Object?> get props => <Object?>[applicationId, ruleVersion];
}

class EvaluateFieldEntity extends Equatable {
  const EvaluateFieldEntity({
    required this.fieldId,
    required this.type,
    required this.value,
    required this.mandatory,
    required this.editable,
    required this.visible,
    required this.validation,
    this.options = const <String>[],
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

  @override
  List<Object?> get props => <Object?>[
    fieldId,
    type,
    value,
    mandatory,
    editable,
    visible,
    validation,
    options,
    dataSource,
    optionVersion,
  ];
}

class EvaluateSectionEntity extends Equatable {
  const EvaluateSectionEntity({
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
  final List<EvaluateFieldEntity> fields;

  @override
  List<Object?> get props => <Object?>[
    sectionId,
    mandatory,
    editable,
    visible,
    status,
    fields,
  ];
}

class EvaluateActionEntity extends Equatable {
  const EvaluateActionEntity({
    required this.actionId,
    required this.triggerField,
  });

  final String actionId;
  final String triggerField;

  @override
  List<Object?> get props => <Object?>[actionId, triggerField];
}

class EvaluateResponseEntity extends Equatable {
  const EvaluateResponseEntity({
    required this.ruleVersion,
    required this.applicationId,
    required this.phase,
    required this.sections,
    required this.actions,
  });

  final String ruleVersion;
  final String applicationId;
  final String phase;
  final List<EvaluateSectionEntity> sections;
  final List<EvaluateActionEntity> actions;

  @override
  List<Object?> get props => <Object?>[
    ruleVersion,
    applicationId,
    phase,
    sections,
    actions,
  ];
}

class ActionResponseEntity extends Equatable {
  const ActionResponseEntity({
    required this.success,
    required this.updatedFields,
    required this.fieldLocks,
    required this.message,
  });

  final bool success;
  final Map<String, dynamic> updatedFields;
  final List<String> fieldLocks;
  final String message;

  @override
  List<Object?> get props => <Object?>[
    success,
    updatedFields,
    fieldLocks,
    message,
  ];
}

class SubmitResponseEntity extends Equatable {
  const SubmitResponseEntity({
    required this.success,
    this.nextPhase,
    this.missingMandatorySections,
  });

  final bool success;
  final String? nextPhase;
  final List<String>? missingMandatorySections;

  @override
  List<Object?> get props => <Object?>[
    success,
    nextPhase,
    missingMandatorySections,
  ];
}
