import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/action_response_entity.dart';
import '../repositories/application_repository.dart';

class ActionParams {
  const ActionParams({
    required this.applicationId,
    required this.actionId,
    required this.payload,
  });

  final String applicationId;
  final String actionId;
  final Map<String, dynamic> payload;
}

class ActionUseCase implements UseCase<ActionResponseEntity, ActionParams> {
  ActionUseCase(this._repository);

  final ApplicationRepository _repository;

  @override
  Future<Either<Failure, ActionResponseEntity>> call(ActionParams params) {
    return _repository.executeAction(
      applicationId: params.applicationId,
      actionId: params.actionId,
      payload: params.payload,
    );
  }
}
