import 'package:equatable/equatable.dart';

import 'action_entity.dart';
import 'section_entity.dart';

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
  final List<SectionEntity> sections;
  final List<ActionEntity> actions;

  EvaluateResponseEntity copyWith({List<SectionEntity>? sections}) {
    return EvaluateResponseEntity(
      ruleVersion: ruleVersion,
      applicationId: applicationId,
      phase: phase,
      sections: sections ?? this.sections,
      actions: actions,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        ruleVersion,
        applicationId,
        phase,
        sections,
        actions,
      ];
}
