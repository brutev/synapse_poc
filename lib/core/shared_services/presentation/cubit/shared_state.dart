import 'package:equatable/equatable.dart';

class SharedState extends Equatable {
  const SharedState({this.loading = false});

  final bool loading;

  @override
  List<Object?> get props => <Object?>[loading];
}
