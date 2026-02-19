import 'package:equatable/equatable.dart';

class DeviceInfoEntity extends Equatable {
  const DeviceInfoEntity({required this.deviceId});

  final String deviceId;

  @override
  List<Object?> get props => <Object?>[deviceId];
}
