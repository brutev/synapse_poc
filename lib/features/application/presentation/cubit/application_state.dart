import 'package:equatable/equatable.dart';

import '../../domain/entities/evaluate_response_entity.dart';
import '../../domain/entities/submit_response_entity.dart';

enum ApplicationStatus { initial, loading, loaded, error }

class ApplicationState extends Equatable {
  const ApplicationState({
    this.status = ApplicationStatus.initial,
    this.applicationId,
    this.ruleVersion,
    this.evaluate,
    this.draftSectionData = const <String, Map<String, dynamic>>{},
    this.errorMessage,
    this.infoMessage,
    this.submitResponse,
  });

  final ApplicationStatus status;
  final String? applicationId;
  final String? ruleVersion;
  final EvaluateResponseEntity? evaluate;
  final Map<String, Map<String, dynamic>> draftSectionData;
  final String? errorMessage;
  final String? infoMessage;
  final SubmitResponseEntity? submitResponse;

  ApplicationState copyWith({
    ApplicationStatus? status,
    String? applicationId,
    String? ruleVersion,
    EvaluateResponseEntity? evaluate,
    Map<String, Map<String, dynamic>>? draftSectionData,
    String? errorMessage,
    String? infoMessage,
    SubmitResponseEntity? submitResponse,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return ApplicationState(
      status: status ?? this.status,
      applicationId: applicationId ?? this.applicationId,
      ruleVersion: ruleVersion ?? this.ruleVersion,
      evaluate: evaluate ?? this.evaluate,
      draftSectionData: draftSectionData ?? this.draftSectionData,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      submitResponse: submitResponse ?? this.submitResponse,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        applicationId,
        ruleVersion,
        evaluate,
        draftSectionData,
        errorMessage,
        infoMessage,
        submitResponse,
      ];
}
