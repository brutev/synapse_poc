import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/evaluate_response_entity.dart';
import '../repositories/application_repository.dart';

class EvaluateParams {
  const EvaluateParams({
    required this.applicationId,
    required this.phase,
    required this.context,
    required this.sectionData,
  });

  final String applicationId;
  final String phase;
  final Map<String, dynamic> context;
  final Map<String, dynamic> sectionData;
}

class EvaluateUseCase
    implements UseCase<EvaluateResponseEntity, EvaluateParams> {
  EvaluateUseCase(this._repository);

  final ApplicationRepository _repository;

  @override
  Future<Either<Failure, EvaluateResponseEntity>> call(EvaluateParams params) {
    return _repository.evaluate(
      applicationId: params.applicationId,
      phase: params.phase,
      context: params.context,
      sectionData: params.sectionData,
    );
  }
}
