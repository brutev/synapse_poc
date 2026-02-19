import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  Future<bool> get hasConnection async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
