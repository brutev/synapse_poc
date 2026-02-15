import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/action_response_entity.dart';
import '../entities/application_created_entity.dart';
import '../entities/evaluate_response_entity.dart';
import '../entities/submit_response_entity.dart';

abstract class ApplicationRepository {
  Future<Either<Failure, ApplicationCreatedEntity>> createApplication();

  Future<Either<Failure, EvaluateResponseEntity>> evaluate({
    required String applicationId,
    required String phase,
    required Map<String, dynamic> context,
    required Map<String, dynamic> sectionData,
  });

  Future<Either<Failure, ActionResponseEntity>> executeAction({
    required String applicationId,
    required String actionId,
    required Map<String, dynamic> payload,
  });

  Future<Either<Failure, void>> saveDraft({
    required String applicationId,
    required String sectionId,
    required Map<String, dynamic> data,
  });

  Future<Either<Failure, SubmitResponseEntity>> submit({
    required String applicationId,
  });
}
