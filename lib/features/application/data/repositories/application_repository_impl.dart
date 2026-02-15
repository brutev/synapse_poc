import 'package:dartz/dartz.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/action_response_entity.dart';
import '../../domain/entities/application_created_entity.dart';
import '../../domain/entities/evaluate_response_entity.dart';
import '../../domain/entities/submit_response_entity.dart';
import '../../domain/repositories/application_repository.dart';
import '../datasources/application_remote_datasource.dart';
import '../models/action_request_model.dart';
import '../models/evaluate_request_model.dart';
import '../models/save_draft_request_model.dart';
import '../models/submit_request_model.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  ApplicationRepositoryImpl(this._remoteDataSource);

  final ApplicationRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, ApplicationCreatedEntity>> createApplication() async {
    try {
      final model = await _remoteDataSource.createApplication();
      return Right<Failure, ApplicationCreatedEntity>(model.toEntity());
    } on Exception catch (exception) {
      return Left<Failure, ApplicationCreatedEntity>(
        ErrorMapper.mapExceptionToFailure(exception),
      );
    }
  }

  @override
  Future<Either<Failure, EvaluateResponseEntity>> evaluate({
    required String applicationId,
    required String phase,
    required Map<String, dynamic> context,
    required Map<String, dynamic> sectionData,
  }) async {
    try {
      final model = await _remoteDataSource.evaluate(
        EvaluateRequestModel(
          applicationId: applicationId,
          phase: phase,
          context: context,
          sectionData: sectionData,
        ),
      );
      return Right<Failure, EvaluateResponseEntity>(model.toEntity());
    } on Exception catch (exception) {
      return Left<Failure, EvaluateResponseEntity>(
        ErrorMapper.mapExceptionToFailure(exception),
      );
    }
  }

  @override
  Future<Either<Failure, ActionResponseEntity>> executeAction({
    required String applicationId,
    required String actionId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final model = await _remoteDataSource.executeAction(
        ActionRequestModel(
          applicationId: applicationId,
          actionId: actionId,
          payload: payload,
        ),
      );
      return Right<Failure, ActionResponseEntity>(model.toEntity());
    } on Exception catch (exception) {
      return Left<Failure, ActionResponseEntity>(
        ErrorMapper.mapExceptionToFailure(exception),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveDraft({
    required String applicationId,
    required String sectionId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _remoteDataSource.saveDraft(
        SaveDraftRequestModel(
          applicationId: applicationId,
          sectionId: sectionId,
          data: data,
        ),
      );
      return const Right<Failure, void>(null);
    } on Exception catch (exception) {
      return Left<Failure, void>(ErrorMapper.mapExceptionToFailure(exception));
    }
  }

  @override
  Future<Either<Failure, SubmitResponseEntity>> submit({
    required String applicationId,
  }) async {
    try {
      final model = await _remoteDataSource.submit(
        SubmitRequestModel(applicationId: applicationId),
      );
      return Right<Failure, SubmitResponseEntity>(model.toEntity());
    } on Exception catch (exception) {
      return Left<Failure, SubmitResponseEntity>(
        ErrorMapper.mapExceptionToFailure(exception),
      );
    }
  }
}
