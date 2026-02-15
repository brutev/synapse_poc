import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../domain/entities/evaluate_response_entity.dart';
import '../../domain/entities/field_entity.dart';
import '../../domain/entities/section_entity.dart';
import '../../domain/usecases/action_usecase.dart';
import '../../domain/usecases/create_application_usecase.dart';
import '../../domain/usecases/evaluate_usecase.dart';
import '../../domain/usecases/save_draft_usecase.dart';
import '../../domain/usecases/submit_usecase.dart';
import 'application_state.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  ApplicationCubit({
    required CreateApplicationUseCase createApplicationUseCase,
    required EvaluateUseCase evaluateUseCase,
    required ActionUseCase actionUseCase,
    required SaveDraftUseCase saveDraftUseCase,
    required SubmitUseCase submitUseCase,
  })  : _createApplicationUseCase = createApplicationUseCase,
        _evaluateUseCase = evaluateUseCase,
        _actionUseCase = actionUseCase,
        _saveDraftUseCase = saveDraftUseCase,
        _submitUseCase = submitUseCase,
        super(const ApplicationState());

  final CreateApplicationUseCase _createApplicationUseCase;
  final EvaluateUseCase _evaluateUseCase;
  final ActionUseCase _actionUseCase;
  final SaveDraftUseCase _saveDraftUseCase;
  final SubmitUseCase _submitUseCase;

  Future<void> loadApplication() async {
    emit(state.copyWith(status: ApplicationStatus.loading, clearError: true));

    final createResult = await _createApplicationUseCase(const NoParams());

    await createResult.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: ApplicationStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (created) async {
        emit(
          state.copyWith(
            applicationId: created.applicationId,
            ruleVersion: created.ruleVersion,
          ),
        );

        await refreshEvaluate(
          phase: AppConstants.initialPhase,
          context: const <String, dynamic>{},
        );
      },
    );
  }

  Future<void> refreshEvaluate({
    String? phase,
    Map<String, dynamic> context = const <String, dynamic>{},
  }) async {
    final String? applicationId = state.applicationId;
    if (applicationId == null) {
      return;
    }

    emit(state.copyWith(status: ApplicationStatus.loading, clearError: true));

    final String resolvedPhase =
        phase ?? state.evaluate?.phase ?? AppConstants.initialPhase;
    final Map<String, dynamic> flattenedDraftData = _flattenDraftData(
      state.draftSectionData,
    );

    final result = await _evaluateUseCase(
      EvaluateParams(
        applicationId: applicationId,
        phase: resolvedPhase,
        context: context,
        sectionData: flattenedDraftData,
      ),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ApplicationStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (evaluate) {
        emit(
          state.copyWith(
            status: ApplicationStatus.loaded,
            evaluate: evaluate,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> executeAction({
    required String actionId,
    required Map<String, dynamic> payload,
  }) async {
    final String? applicationId = state.applicationId;
    final EvaluateResponseEntity? currentEvaluate = state.evaluate;
    if (applicationId == null || currentEvaluate == null) {
      return;
    }

    emit(
      state.copyWith(
        status: ApplicationStatus.loading,
        clearError: true,
        clearInfo: true,
      ),
    );

    final result = await _actionUseCase(
      ActionParams(
        applicationId: applicationId,
        actionId: actionId,
        payload: payload,
      ),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ApplicationStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (response) {
        final EvaluateResponseEntity updatedEvaluate = _applyActionResponse(
          currentEvaluate,
          response.updatedFields,
          response.fieldLocks,
        );

        emit(
          state.copyWith(
            status: ApplicationStatus.loaded,
            evaluate: updatedEvaluate,
            infoMessage: response.message,
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> saveDraft({required String sectionId}) async {
    final String? applicationId = state.applicationId;
    if (applicationId == null) {
      return;
    }

    final Map<String, dynamic> sectionData =
        state.draftSectionData[sectionId] ?? <String, dynamic>{};

    final result = await _saveDraftUseCase(
      SaveDraftParams(
        applicationId: applicationId,
        sectionId: sectionId,
        data: sectionData,
      ),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ApplicationStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            status: ApplicationStatus.loaded,
            infoMessage: 'Draft saved',
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> submit() async {
    final String? applicationId = state.applicationId;
    if (applicationId == null) {
      return;
    }

    emit(
      state.copyWith(
        status: ApplicationStatus.loading,
        clearError: true,
        clearInfo: true,
      ),
    );

    final result = await _submitUseCase(
      SubmitParams(applicationId: applicationId),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ApplicationStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (response) {
        emit(
          state.copyWith(
            status: ApplicationStatus.loaded,
            submitResponse: response,
            infoMessage: response.success
                ? 'Submitted successfully'
                : 'Missing sections: ${response.missingMandatorySections?.join(', ') ?? ''}',
            clearError: true,
          ),
        );
      },
    );
  }

  void updateFieldValue({
    required String sectionId,
    required String fieldId,
    required Object? value,
  }) {
    final Map<String, Map<String, dynamic>> updatedDraft =
        Map<String, Map<String, dynamic>>.from(state.draftSectionData);
    final Map<String, dynamic> sectionMap = Map<String, dynamic>.from(
      updatedDraft[sectionId] ?? <String, dynamic>{},
    );
    sectionMap[fieldId] = value;
    updatedDraft[sectionId] = sectionMap;

    emit(state.copyWith(draftSectionData: updatedDraft));
  }

  EvaluateResponseEntity _applyActionResponse(
    EvaluateResponseEntity source,
    Map<String, dynamic> updatedFields,
    List<String> fieldLocks,
  ) {
    final Set<String> locks = fieldLocks.toSet();

    final List<SectionEntity> sections = source.sections.map((
      SectionEntity section,
    ) {
      final List<FieldEntity> fields = section.fields.map((FieldEntity field) {
        final bool containsValue = updatedFields.containsKey(field.fieldId);
        if (containsValue) {
          return field.copyWith(
            value: updatedFields[field.fieldId],
            editable: locks.contains(field.fieldId) ? false : field.editable,
          );
        }
        return field.copyWith(
          editable: locks.contains(field.fieldId) ? false : field.editable,
        );
      }).toList();

      return section.copyWith(fields: fields);
    }).toList();

    return source.copyWith(sections: sections);
  }

  Map<String, dynamic> _flattenDraftData(
    Map<String, Map<String, dynamic>> draftBySection,
  ) {
    return draftBySection.map(
      (String sectionId, Map<String, dynamic> fields) =>
          MapEntry<String, dynamic>(sectionId, fields),
    );
  }
}
