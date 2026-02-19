import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestLocation() async =>
      (await Permission.location.request()).isGranted;
}
