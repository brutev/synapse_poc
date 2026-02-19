import '../repositories/form_engine_repository.dart';

class SaveDraftUseCase {
  const SaveDraftUseCase(this._repository);

  final FormEngineRepository _repository;

  Future<void> call({
    required String applicationId,
    required String sectionId,
    required String scenarioId,
    required Map<String, dynamic> values,
  }) {
    return _repository.saveDraft(
      applicationId: applicationId,
      sectionId: sectionId,
      scenarioId: scenarioId,
      values: values,
    );
  }
}
