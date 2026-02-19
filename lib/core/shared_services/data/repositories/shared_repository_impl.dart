import '../../domain/entities/auth_entities.dart';
import '../../domain/entities/device_info_entities.dart';
import '../../domain/repositories/shared_repository.dart';

class SharedRepositoryImpl implements SharedRepository {
  @override
  Future<AuthEntity> login() async => const AuthEntity(token: '');

  @override
  Future<List<String>> getMasterData() async => const <String>[];

  @override
  Future<DeviceInfoEntity> getDeviceInfo() async =>
      const DeviceInfoEntity(deviceId: '');
}
