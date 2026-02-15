import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failures.dart';

class ErrorMapper {
  static Exception mapDioException(DioException exception) {
    if (exception.type == DioExceptionType.connectionError ||
        exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.sendTimeout) {
      return NetworkException('Network error occurred');
    }

    final int? statusCode = exception.response?.statusCode;
    if (statusCode != null) {
      final Object? message = exception.response?.data;
      return ServerException(
        message?.toString() ?? 'Server error: $statusCode',
      );
    }

    return UnknownException('Unexpected error occurred');
  }

  static Failure mapExceptionToFailure(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    }
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    }
    if (exception is UnknownException) {
      return UnknownFailure(exception.message);
    }
    return UnknownFailure('Unexpected failure occurred');
  }
}
