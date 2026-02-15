import '../../domain/entities/submit_response_entity.dart';

class SubmitResponseModel {
  const SubmitResponseModel({
    required this.success,
    this.nextPhase,
    this.missingMandatorySections,
  });

  final bool success;
  final String? nextPhase;
  final List<String>? missingMandatorySections;

  factory SubmitResponseModel.fromJson(Map<String, dynamic> json) {
    return SubmitResponseModel(
      success: json['success'] as bool,
      nextPhase: json['nextPhase'] as String?,
      missingMandatorySections:
          (json['missingMandatorySections'] as List<dynamic>?)?.cast<String>(),
    );
  }

  SubmitResponseEntity toEntity() {
    return SubmitResponseEntity(
      success: success,
      nextPhase: nextPhase,
      missingMandatorySections: missingMandatorySections,
    );
  }
}
