import '../entities/device_info_entities.dart';
import '../repositories/shared_repository.dart';

class DeviceInfoUseCase {
  const DeviceInfoUseCase(this._repository);

  final SharedRepository _repository;

  Future<DeviceInfoEntity> call() => _repository.getDeviceInfo();
}
