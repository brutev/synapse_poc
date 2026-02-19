import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_service_url.dart';
import '../error/error_handler.dart';
import 'api_loader_interceptor.dart';
import 'api_logger.dart';
import 'base_api_service.dart';

class NetworkApiService implements BaseApiService {
  NetworkApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppServiceUrl.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      ) {
    _dio.interceptors.addAll(<Interceptor>[
      ApiLoaderInterceptor(),
      buildApiLogger(),
    ]);
  }

  final Dio _dio;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(milliseconds: 500);

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      _logSuccess('GET', path, response);
      return response.data;
    } on DioException catch (e) {
      _handleError('GET', path, e);
    }
  }

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        path,
        data: body,
        queryParameters: queryParameters,
      );
      _logSuccess('POST', path, response);
      return response.data;
    } on DioException catch (e) {
      _handleError('POST', path, e);
    }
  }

  /// POST with automatic retry (exponential backoff)
  Future<dynamic> postWithRetry(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    int attempt = 0;
    DioException? lastError;

    while (attempt < maxRetries) {
      try {
        debugPrint('🔄 [POST] Attempt ${attempt + 1}/$maxRetries: $path');
        final Response<dynamic> response = await _dio.post<dynamic>(
          path,
          data: body,
          queryParameters: queryParameters,
        );
        _logSuccess('POST', path, response);
        return response.data;
      } on DioException catch (e) {
        lastError = e;

        // Don't retry on client errors (4xx)
        if (e.response?.statusCode != null && e.response!.statusCode! >= 400 && e.response!.statusCode! < 500) {
          debugPrint('❌ [POST] Client error, not retrying: ${e.response?.statusCode}');
          _handleError('POST', path, e);
        }

        // Retry on network errors or server errors
        if (attempt < maxRetries - 1) {
          final backoffMs = retryDelay.inMilliseconds * (1 << attempt);
          debugPrint('⏳ [POST] Retrying after ${backoffMs}ms...');
          await Future<void>.delayed(Duration(milliseconds: backoffMs));
          attempt++;
        } else {
          break;
        }
      }
    }

    // All retries exhausted
    if (lastError != null) {
      _handleError('POST', path, lastError);
    }
  }

  @override
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response<dynamic> response = await _dio.put<dynamic>(
        path,
        data: body,
        queryParameters: queryParameters,
      );
      _logSuccess('PUT', path, response);
      return response.data;
    } on DioException catch (e) {
      _handleError('PUT', path, e);
    }
  }

  @override
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response<dynamic> response = await _dio.patch<dynamic>(
        path,
        data: body,
        queryParameters: queryParameters,
      );
      _logSuccess('PATCH', path, response);
      return response.data;
    } on DioException catch (e) {
      _handleError('PATCH', path, e);
    }
  }

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    try {
      final Response<dynamic> response = await _dio.delete<dynamic>(
        path,
        queryParameters: queryParameters,
        data: body,
      );
      _logSuccess('DELETE', path, response);
      return response.data;
    } on DioException catch (e) {
      _handleError('DELETE', path, e);
    }
  }

  @override
  Future<dynamic> head(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response<dynamic> response = await _dio.head<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      _logSuccess('HEAD', path, response);
      return response.data;
    } on DioException catch (e) {
      _handleError('HEAD', path, e);
    }
  }

  void _logSuccess(String method, String path, Response<dynamic> response) {
    debugPrint(
      '\n✅ [API Response] $method $path'
      '\n   Status: ${response.statusCode}'
      '\n   Data: ${response.data}'
      '\n',
    );
  }

  void _handleError(String method, String path, DioException error) {
    final String errorMsg = _mapErrorToUserFriendlyMessage(error);

    debugPrint(
      '\n❌ [API Error] $method $path'
      '\n   Type: ${error.type}'
      '\n   Status: ${error.response?.statusCode}'
      '\n   Message: $errorMsg'
      '\n   URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}'
      '\n',
    );

    ErrorHandler.handleNetworkError(errorMsg);
    throw errorMsg;
  }

  String _mapErrorToUserFriendlyMessage(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout =>
        'Connection timeout. Please check your internet connection.',
      DioExceptionType.sendTimeout =>
        'Request took too long. Please check your connection.',
      DioExceptionType.receiveTimeout =>
        'Response took too long. Server may be busy.',
      DioExceptionType.badResponse => _mapStatusCodeToMessage(
        error.response?.statusCode,
        error.response?.data,
      ),
      DioExceptionType.cancel => 'Request was cancelled.',
      DioExceptionType.connectionError =>
        'No internet connection. Please try again.',
      DioExceptionType.unknown =>
        'Network error. Please try again.',
      _ => 'An error occurred. Please try again.',
    };
  }

  String _mapStatusCodeToMessage(int? statusCode, dynamic responseData) {
    return switch (statusCode) {
      400 => 'Invalid request. Please check your input.',
      401 => 'Session expired. Please login again.',
      403 => 'You do not have permission to perform this action.',
      404 => 'Resource not found.',
      500 || 502 || 503 =>
        'Server error. Please try again in a few moments.',
      _ => 'Server error (${statusCode ?? 'unknown'}). Please try again.',
    };
  }
}
