import 'package:equatable/equatable.dart';

class ActionResponseEntity extends Equatable {
  const ActionResponseEntity({
    required this.success,
    required this.updatedFields,
    required this.fieldLocks,
    required this.message,
  });

  final bool success;
  final Map<String, dynamic> updatedFields;
  final List<String> fieldLocks;
  final String message;

  @override
  List<Object?> get props => <Object?>[
        success,
        updatedFields,
        fieldLocks,
        message,
      ];
}
