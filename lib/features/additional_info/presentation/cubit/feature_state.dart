import 'package:equatable/equatable.dart';

class FeatureState extends Equatable {
  const FeatureState({this.loading = false});

  final bool loading;

  @override
  List<Object?> get props => <Object?>[loading];
}
