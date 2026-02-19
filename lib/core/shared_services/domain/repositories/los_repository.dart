import '../entities/los_entities.dart';

abstract class LosRepository {
  Future<ApplicationCreatedEntity> createApplication();

  Future<EvaluateResponseEntity> evaluate({
    required String applicationId,
    required String phase,
    required Map<String, dynamic> context,
    required Map<String, dynamic> sectionData,
  });

  Future<ActionResponseEntity> executeAction({
    required String applicationId,
    required String actionId,
    required Map<String, dynamic> payload,
  });

  Future<void> saveDraft({
    required String applicationId,
    required String sectionId,
    required Map<String, dynamic> data,
  });

  Future<SubmitResponseEntity> submit({required String applicationId});
}
