import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/application_created_entity.dart';
import '../repositories/application_repository.dart';

class CreateApplicationUseCase
    implements UseCase<ApplicationCreatedEntity, NoParams> {
  CreateApplicationUseCase(this._repository);

  final ApplicationRepository _repository;

  @override
  Future<Either<Failure, ApplicationCreatedEntity>> call(NoParams params) {
    return _repository.createApplication();
  }
}
