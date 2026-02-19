import '../entities/los_entities.dart';
import '../repositories/los_repository.dart';

class EvaluateLosUseCase {
  const EvaluateLosUseCase(this._repository);

  final LosRepository _repository;

  Future<EvaluateResponseEntity> call({
    required String applicationId,
    required String phase,
    required Map<String, dynamic> context,
    required Map<String, dynamic> sectionData,
  }) {
    return _repository.evaluate(
      applicationId: applicationId,
      phase: phase,
      context: context,
      sectionData: sectionData,
    );
  }
}
