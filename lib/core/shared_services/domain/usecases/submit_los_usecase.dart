import '../entities/los_entities.dart';
import '../repositories/los_repository.dart';

class SubmitLosUseCase {
  const SubmitLosUseCase(this._repository);

  final LosRepository _repository;

  Future<SubmitResponseEntity> call({required String applicationId}) {
    return _repository.submit(applicationId: applicationId);
  }
}
