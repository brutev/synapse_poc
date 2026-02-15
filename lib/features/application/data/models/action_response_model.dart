import '../../domain/entities/action_response_entity.dart';

class ActionResponseModel {
  const ActionResponseModel({
    required this.success,
    required this.updatedFields,
    required this.fieldLocks,
    required this.message,
  });

  final bool success;
  final Map<String, dynamic> updatedFields;
  final List<String> fieldLocks;
  final String message;

  factory ActionResponseModel.fromJson(Map<String, dynamic> json) {
    return ActionResponseModel(
      success: json['success'] as bool,
      updatedFields: (json['updatedFields'] as Map<String, dynamic>),
      fieldLocks: (json['fieldLocks'] as List<dynamic>).cast<String>(),
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'success': success,
      'updatedFields': updatedFields,
      'fieldLocks': fieldLocks,
      'message': message,
    };
  }

  ActionResponseEntity toEntity() {
    return ActionResponseEntity(
      success: success,
      updatedFields: updatedFields,
      fieldLocks: fieldLocks,
      message: message,
    );
  }
}
