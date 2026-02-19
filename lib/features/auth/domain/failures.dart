import 'package:equatable/equatable.dart';

abstract class AuthFailure extends Equatable {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

class LoginFailure extends AuthFailure {
  const LoginFailure(super.message);
}

class LogoutFailure extends AuthFailure {
  const LogoutFailure(super.message);
}

class SessionExpiredFailure extends AuthFailure {
  const SessionExpiredFailure(super.message);
}
