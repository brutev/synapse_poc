import '../repositories/los_repository.dart';

class SaveLosDraftUseCase {
  const SaveLosDraftUseCase(this._repository);

  final LosRepository _repository;

  Future<void> call({
    required String applicationId,
    required String sectionId,
    required Map<String, dynamic> data,
  }) {
    return _repository.saveDraft(
      applicationId: applicationId,
      sectionId: sectionId,
      data: data,
    );
  }
}
