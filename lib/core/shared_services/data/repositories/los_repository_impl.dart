import '../../domain/entities/los_entities.dart';
import '../../domain/repositories/los_repository.dart';
import '../datasources/los_remote_datasource.dart';

class LosRepositoryImpl implements LosRepository {
  LosRepositoryImpl(this._remoteDataSource);

  final LosRemoteDataSource _remoteDataSource;

  @override
  Future<ApplicationCreatedEntity> createApplication() async {
    final model = await _remoteDataSource.createApplication();
    return model.toEntity();
  }

  @override
  Future<EvaluateResponseEntity> evaluate({
    required String applicationId,
    required String phase,
    required Map<String, dynamic> context,
    required Map<String, dynamic> sectionData,
  }) async {
    final model = await _remoteDataSource.evaluate(
      applicationId: applicationId,
      phase: phase,
      context: context,
      sectionData: sectionData,
    );
    return model.toEntity();
  }

  @override
  Future<ActionResponseEntity> executeAction({
    required String applicationId,
    required String actionId,
    required Map<String, dynamic> payload,
  }) async {
    final model = await _remoteDataSource.executeAction(
      applicationId: applicationId,
      actionId: actionId,
      payload: payload,
    );
    return model.toEntity();
  }

  @override
  Future<void> saveDraft({
    required String applicationId,
    required String sectionId,
    required Map<String, dynamic> data,
  }) {
    return _remoteDataSource.saveDraft(
      applicationId: applicationId,
      sectionId: sectionId,
      data: data,
    );
  }

  @override
  Future<SubmitResponseEntity> submit({required String applicationId}) async {
    final model = await _remoteDataSource.submit(applicationId: applicationId);
    return model.toEntity();
  }
}
