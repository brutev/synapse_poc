import '../../domain/entities/application_created_entity.dart';

class CreateApplicationResponseModel {
  const CreateApplicationResponseModel({
    required this.applicationId,
    required this.ruleVersion,
  });

  final String applicationId;
  final String ruleVersion;

  factory CreateApplicationResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateApplicationResponseModel(
      applicationId: json['applicationId'] as String,
      ruleVersion: json['ruleVersion'] as String,
    );
  }

  ApplicationCreatedEntity toEntity() {
    return ApplicationCreatedEntity(
      applicationId: applicationId,
      ruleVersion: ruleVersion,
    );
  }
}
