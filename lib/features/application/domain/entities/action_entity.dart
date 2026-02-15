import 'package:equatable/equatable.dart';

class ActionEntity extends Equatable {
  const ActionEntity({required this.actionId, required this.triggerField});

  final String actionId;
  final String triggerField;

  @override
  List<Object?> get props => <Object?>[actionId, triggerField];
}
