import 'package:equatable/equatable.dart';

import '../../domain/entities/los_entities.dart';

enum ApplicationFlowStatus { initial, loading, ready, error }

class ProposalSummary extends Equatable {
  const ProposalSummary({
    required this.applicationId,
    required this.phase,
    required this.progress,
  });

  final String applicationId;
  final String phase;
  final double progress;

  @override
  List<Object?> get props => <Object?>[applicationId, phase, progress];
}

class ApplicationFlowState extends Equatable {
  const ApplicationFlowState({
    this.status = ApplicationFlowStatus.initial,
    this.errorMessage,
    this.currentApplicationId,
    this.currentRuleVersion,
    this.currentPhase = 'PRE_SANCTION',
    this.evaluate,
    this.proposals = const <ProposalSummary>[],
    this.sectionData = const <String, dynamic>{},
  });

  final ApplicationFlowStatus status;
  final String? errorMessage;
  final String? currentApplicationId;
  final String? currentRuleVersion;
  final String currentPhase;
  final EvaluateResponseEntity? evaluate;
  final List<ProposalSummary> proposals;
  final Map<String, dynamic> sectionData;

  ApplicationFlowState copyWith({
    ApplicationFlowStatus? status,
    String? errorMessage,
    String? currentApplicationId,
    String? currentRuleVersion,
    String? currentPhase,
    EvaluateResponseEntity? evaluate,
    List<ProposalSummary>? proposals,
    Map<String, dynamic>? sectionData,
    bool clearError = false,
  }) {
    return ApplicationFlowState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentApplicationId: currentApplicationId ?? this.currentApplicationId,
      currentRuleVersion: currentRuleVersion ?? this.currentRuleVersion,
      currentPhase: currentPhase ?? this.currentPhase,
      evaluate: evaluate ?? this.evaluate,
      proposals: proposals ?? this.proposals,
      sectionData: sectionData ?? this.sectionData,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    errorMessage,
    currentApplicationId,
    currentRuleVersion,
    currentPhase,
    evaluate,
    proposals,
    sectionData,
  ];
}
