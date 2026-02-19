import '../entities/auth_entities.dart';
import '../entities/device_info_entities.dart';

abstract class SharedRepository {
  Future<AuthEntity> login();
  Future<List<String>> getMasterData();
  Future<DeviceInfoEntity> getDeviceInfo();
}
