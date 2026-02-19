import '../entities/los_entities.dart';
import '../repositories/los_repository.dart';

class CreateLosApplicationUseCase {
  const CreateLosApplicationUseCase(this._repository);

  final LosRepository _repository;

  Future<ApplicationCreatedEntity> call() => _repository.createApplication();
}
