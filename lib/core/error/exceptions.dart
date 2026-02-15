class ServerException implements Exception {
  const ServerException(this.message);

  final String message;
}

class NetworkException implements Exception {
  const NetworkException(this.message);

  final String message;
}

class UnknownException implements Exception {
  const UnknownException(this.message);

  final String message;
}
