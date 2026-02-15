import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/submit_response_entity.dart';
import '../repositories/application_repository.dart';

class SubmitParams {
  const SubmitParams({required this.applicationId});

  final String applicationId;
}

class SubmitUseCase implements UseCase<SubmitResponseEntity, SubmitParams> {
  SubmitUseCase(this._repository);

  final ApplicationRepository _repository;

  @override
  Future<Either<Failure, SubmitResponseEntity>> call(SubmitParams params) {
    return _repository.submit(applicationId: params.applicationId);
  }
}
