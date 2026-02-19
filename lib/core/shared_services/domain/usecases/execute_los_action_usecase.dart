import '../entities/los_entities.dart';
import '../repositories/los_repository.dart';

class ExecuteLosActionUseCase {
  const ExecuteLosActionUseCase(this._repository);

  final LosRepository _repository;

  Future<ActionResponseEntity> call({
    required String applicationId,
    required String actionId,
    required Map<String, dynamic> payload,
  }) {
    return _repository.executeAction(
      applicationId: applicationId,
      actionId: actionId,
      payload: payload,
    );
  }
}
