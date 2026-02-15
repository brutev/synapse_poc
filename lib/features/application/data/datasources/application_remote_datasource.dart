import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/action_request_model.dart';
import '../models/action_response_model.dart';
import '../models/create_application_response_model.dart';
import '../models/evaluate_request_model.dart';
import '../models/evaluate_response_model.dart';
import '../models/save_draft_request_model.dart';
import '../models/submit_request_model.dart';
import '../models/submit_response_model.dart';

abstract class ApplicationRemoteDataSource {
  Future<CreateApplicationResponseModel> createApplication();

  Future<EvaluateResponseModel> evaluate(EvaluateRequestModel request);

  Future<ActionResponseModel> executeAction(ActionRequestModel request);

  Future<void> saveDraft(SaveDraftRequestModel request);

  Future<SubmitResponseModel> submit(SubmitRequestModel request);
}

class ApplicationRemoteDataSourceImpl implements ApplicationRemoteDataSource {
  ApplicationRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<CreateApplicationResponseModel> createApplication() async {
    final response = await _apiClient.post(ApiEndpoints.applications);
    return CreateApplicationResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<EvaluateResponseModel> evaluate(EvaluateRequestModel request) async {
    final response = await _apiClient.post(
      ApiEndpoints.evaluate,
      data: request.toJson(),
    );
    return EvaluateResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ActionResponseModel> executeAction(ActionRequestModel request) async {
    final response = await _apiClient.post(
      ApiEndpoints.action,
      data: request.toJson(),
    );
    return ActionResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> saveDraft(SaveDraftRequestModel request) async {
    await _apiClient.post(ApiEndpoints.saveDraft, data: request.toJson());
  }

  @override
  Future<SubmitResponseModel> submit(SubmitRequestModel request) async {
    final response = await _apiClient.post(
      ApiEndpoints.submit,
      data: request.toJson(),
    );
    return SubmitResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
