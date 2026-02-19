import 'package:equatable/equatable.dart';

class FeatureValidationState extends Equatable {
  const FeatureValidationState({this.isValid = true});

  final bool isValid;

  @override
  List<Object?> get props => <Object?>[isValid];
}
