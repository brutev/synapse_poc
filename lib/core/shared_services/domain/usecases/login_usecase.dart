import '../entities/auth_entities.dart';
import '../repositories/shared_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final SharedRepository _repository;

  Future<AuthEntity> call() => _repository.login();
}
