import 'package:equatable/equatable.dart';

class MasterDataEntity extends Equatable {
  const MasterDataEntity({required this.code, required this.label});

  final String code;
  final String label;

  @override
  List<Object?> get props => <Object?>[code, label];
}
