import '../../../config/app_service_url.dart';
import '../../../network_handler/base_api_service.dart';
import '../models/los_models.dart';

abstract class LosRemoteDataSource {
  Future<ApplicationCreatedModel> createApplication();

  Future<EvaluateResponseModel> evaluate({
    required String applicationId,
    required String phase,
    required Map<String, dynamic> context,
    required Map<String, dynamic> sectionData,
  });

  Future<ActionResponseModel> executeAction({
    required String applicationId,
    required String actionId,
    required Map<String, dynamic> payload,
  });

  Future<void> saveDraft({
    required String applicationId,
    required String sectionId,
    required Map<String, dynamic> data,
  });

  Future<SubmitResponseModel> submit({required String applicationId});
}

class LosRemoteDataSourceImpl implements LosRemoteDataSource {
  LosRemoteDataSourceImpl(this._apiService);

  final BaseApiService _apiService;

  @override
  Future<ApplicationCreatedModel> createApplication() async {
    final response = await _apiService.post(AppServiceUrl.applications);
    return ApplicationCreatedModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<EvaluateResponseModel> evaluate({
    required String applicationId,
    required String phase,
    required Map<String, dynamic> context,
    required Map<String, dynamic> sectionData,
  }) async {
    final response = await _apiService.post(
      AppServiceUrl.evaluate,
      body: <String, dynamic>{
        'applicationId': applicationId,
        'phase': phase,
        'context': context,
        'sectionData': sectionData,
      },
    );
    return EvaluateResponseModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<ActionResponseModel> executeAction({
    required String applicationId,
    required String actionId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _apiService.post(
      AppServiceUrl.action,
      body: <String, dynamic>{
        'applicationId': applicationId,
        'actionId': actionId,
        'payload': payload,
      },
    );
    return ActionResponseModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> saveDraft({
    required String applicationId,
    required String sectionId,
    required Map<String, dynamic> data,
  }) async {
    await _apiService.post(
      AppServiceUrl.saveDraft,
      body: <String, dynamic>{
        'applicationId': applicationId,
        'sectionId': sectionId,
        'data': data,
      },
    );
  }

  @override
  Future<SubmitResponseModel> submit({required String applicationId}) async {
    final response = await _apiService.post(
      AppServiceUrl.submit,
      body: <String, dynamic>{'applicationId': applicationId},
    );
    return SubmitResponseModel.fromJson(response as Map<String, dynamic>);
  }
}
