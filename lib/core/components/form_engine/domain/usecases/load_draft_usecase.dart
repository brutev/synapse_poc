import '../repositories/form_engine_repository.dart';

class LoadDraftUseCase {
  const LoadDraftUseCase(this._repository);

  final FormEngineRepository _repository;

  Future<Map<String, dynamic>> call({
    required String applicationId,
    required String sectionId,
    required String scenarioId,
  }) {
    return _repository.loadDraft(
      applicationId: applicationId,
      sectionId: sectionId,
      scenarioId: scenarioId,
    );
  }
}
