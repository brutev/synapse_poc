import 'package:equatable/equatable.dart';

class SubmitResponseEntity extends Equatable {
  const SubmitResponseEntity({
    required this.success,
    this.nextPhase,
    this.missingMandatorySections,
  });

  final bool success;
  final String? nextPhase;
  final List<String>? missingMandatorySections;

  @override
  List<Object?> get props => <Object?>[
        success,
        nextPhase,
        missingMandatorySections,
      ];
}
