import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/los_entities.dart';
import '../../domain/usecases/create_los_application_usecase.dart';
import '../../domain/usecases/evaluate_los_usecase.dart';
import '../../domain/usecases/execute_los_action_usecase.dart';
import '../../domain/usecases/save_los_draft_usecase.dart';
import '../../domain/usecases/submit_los_usecase.dart';
import '../../../error/error_handler.dart';
import 'application_flow_state.dart';

class ApplicationFlowCubit extends Cubit<ApplicationFlowState> {
  ApplicationFlowCubit({
    required CreateLosApplicationUseCase createApplicationUseCase,
    required EvaluateLosUseCase evaluateUseCase,
    required ExecuteLosActionUseCase executeActionUseCase,
    required SaveLosDraftUseCase saveDraftUseCase,
    required SubmitLosUseCase submitUseCase,
  }) : _createApplicationUseCase = createApplicationUseCase,
       _evaluateUseCase = evaluateUseCase,
       _executeActionUseCase = executeActionUseCase,
       _saveDraftUseCase = saveDraftUseCase,
       _submitUseCase = submitUseCase,
       super(const ApplicationFlowState());

  final CreateLosApplicationUseCase _createApplicationUseCase;
  final EvaluateLosUseCase _evaluateUseCase;
  final ExecuteLosActionUseCase _executeActionUseCase;
  final SaveLosDraftUseCase _saveDraftUseCase;
  final SubmitLosUseCase _submitUseCase;

  Future<void> createProposal() async {
    emit(
      state.copyWith(status: ApplicationFlowStatus.loading, clearError: true),
    );

    try {
      debugPrint('\n🔵 [createProposal] Calling POST /applications...\n');
      final ApplicationCreatedEntity created =
          await _createApplicationUseCase();
      debugPrint(
        '\n✅ [createProposal] Application created: ${created.applicationId}\n',
      );

      debugPrint(
        '\n🔵 [createProposal] Calling POST /evaluate for ${created.applicationId}...\n',
      );
      final EvaluateResponseEntity evaluate = await _evaluateUseCase(
        applicationId: created.applicationId,
        phase: 'PRE_SANCTION',
        context: const <String, dynamic>{},
        sectionData: const <String, dynamic>{},
      );
      debugPrint(
        '\n✅ [createProposal] Form evaluated with ${evaluate.sections.length} sections\n',
      );

      final List<ProposalSummary> proposals =
          List<ProposalSummary>.from(state.proposals)..add(
            ProposalSummary(
              applicationId: created.applicationId,
              phase: evaluate.phase,
              progress: _progress(evaluate.sections),
            ),
          );

      emit(
        state.copyWith(
          status: ApplicationFlowStatus.ready,
          currentApplicationId: created.applicationId,
          currentRuleVersion: created.ruleVersion,
          currentPhase: evaluate.phase,
          evaluate: evaluate,
          proposals: proposals,
          sectionData: const <String, dynamic>{},
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('\n❌ [createProposal] Error: $e\nStack: $stackTrace\n');
      final String errorMsg = _formatErrorMessage(e);
      ErrorHandler.handleGenericError(e, stackTrace);
      emit(
        state.copyWith(
          status: ApplicationFlowStatus.error,
          errorMessage: errorMsg,
        ),
      );
    }
  }

  Future<void> loadApplication(String applicationId) async {
    emit(
      state.copyWith(status: ApplicationFlowStatus.loading, clearError: true),
    );

    try {
      final EvaluateResponseEntity evaluate = await _evaluateUseCase(
        applicationId: applicationId,
        phase: state.currentPhase,
        context: const <String, dynamic>{},
        sectionData: state.sectionData,
      );

      final List<ProposalSummary> updated = _upsertProposal(
        state.proposals,
        applicationId,
        evaluate.phase,
        _progress(evaluate.sections),
      );

      emit(
        state.copyWith(
          status: ApplicationFlowStatus.ready,
          currentApplicationId: applicationId,
          currentPhase: evaluate.phase,
          evaluate: evaluate,
          proposals: updated,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('\n❌ [loadApplication] Error: $e\nStack: $stackTrace\n');
      final String errorMsg = _formatErrorMessage(e);
      ErrorHandler.handleGenericError(e, stackTrace);
      emit(
        state.copyWith(
          status: ApplicationFlowStatus.error,
          errorMessage: errorMsg,
        ),
      );
    }
  }

  Future<void> saveSectionDraft({
    required String applicationId,
    required String sectionId,
    required Map<String, dynamic> data,
  }) async {
    final Map<String, dynamic> mergedSectionData = Map<String, dynamic>.from(
      state.sectionData,
    )..[sectionId] = data;

    emit(state.copyWith(sectionData: mergedSectionData));

    try {
      await _saveDraftUseCase(
        applicationId: applicationId,
        sectionId: sectionId,
        data: data,
      );
      await loadApplication(applicationId);
    } catch (e, stackTrace) {
      debugPrint('\n❌ [saveSectionDraft] Error: $e\nStack: $stackTrace\n');
      final String errorMsg = _formatErrorMessage(e);
      ErrorHandler.handleGenericError(e, stackTrace);
      emit(
        state.copyWith(
          status: ApplicationFlowStatus.error,
          errorMessage: errorMsg,
        ),
      );
    }
  }

  Future<void> executeAction({
    required String applicationId,
    required String actionId,
    required Map<String, dynamic> payload,
  }) async {
    emit(
      state.copyWith(status: ApplicationFlowStatus.loading, clearError: true),
    );

    try {
      await _executeActionUseCase(
        applicationId: applicationId,
        actionId: actionId,
        payload: payload,
      );
      await loadApplication(applicationId);
    } catch (e, stackTrace) {
      debugPrint('\n❌ [executeAction] Error: $e\nStack: $stackTrace\n');
      final String errorMsg = _formatErrorMessage(e);
      ErrorHandler.handleGenericError(e, stackTrace);
      emit(
        state.copyWith(
          status: ApplicationFlowStatus.error,
          errorMessage: errorMsg,
        ),
      );
    }
  }

  Future<SubmitResponseEntity?> submit(String applicationId) async {
    emit(
      state.copyWith(status: ApplicationFlowStatus.loading, clearError: true),
    );

    try {
      final result = await _submitUseCase(applicationId: applicationId);
      emit(state.copyWith(status: ApplicationFlowStatus.ready));
      return result;
    } catch (e, stackTrace) {
      debugPrint('\n❌ [submit] Error: $e\nStack: $stackTrace\n');
      final String errorMsg = _formatErrorMessage(e);
      ErrorHandler.handleGenericError(e, stackTrace);
      emit(
        state.copyWith(
          status: ApplicationFlowStatus.error,
          errorMessage: errorMsg,
        ),
      );
      return null;
    }
  }

  String _formatErrorMessage(Object error) {
    if (error is String) {
      if (error.length > 200) {
        return 'An error occurred. Please try again.';
      }
      return error;
    }
    return 'An error occurred. Please try again.';
  }

  List<ProposalSummary> _upsertProposal(
    List<ProposalSummary> proposals,
    String applicationId,
    String phase,
    double progress,
  ) {
    final List<ProposalSummary> next = List<ProposalSummary>.from(proposals);
    final int idx = next.indexWhere(
      (ProposalSummary item) => item.applicationId == applicationId,
    );

    final ProposalSummary summary = ProposalSummary(
      applicationId: applicationId,
      phase: phase,
      progress: progress,
    );

    if (idx == -1) {
      next.add(summary);
    } else {
      next[idx] = summary;
    }

    return next;
  }

  double _progress(List<EvaluateSectionEntity> sections) {
    if (sections.isEmpty) {
      return 0;
    }
    final int complete = sections
        .where((EvaluateSectionEntity item) => item.status == 'COMPLETED')
        .length;
    return complete / sections.length;
  }
}
