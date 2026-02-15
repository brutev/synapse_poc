import 'package:equatable/equatable.dart';

class ApplicationCreatedEntity extends Equatable {
  const ApplicationCreatedEntity({
    required this.applicationId,
    required this.ruleVersion,
  });

  final String applicationId;
  final String ruleVersion;

  @override
  List<Object?> get props => <Object?>[applicationId, ruleVersion];
}
