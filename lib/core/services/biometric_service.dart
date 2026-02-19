import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService() : _auth = LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> authenticate() async {
    return _auth.authenticate(localizedReason: 'Authenticate');
  }
}
