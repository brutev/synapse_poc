import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'app_exception.dart';
import 'exceptions.dart';
import 'failure.dart';

class ErrorHandler {
  const ErrorHandler._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void setupGlobalErrorHandlers() {
    // Handle Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('❌ [FlutterError] ${details.exception}\n${details.stack}');
      _logErrorToConsole(details.exception.toString(), details.stack.toString());
      _showErrorSnackBar(
        title: 'Application Error',
        message: 'An unexpected error occurred. Please restart the app.',
      );
    };

    // Handle platform errors
    ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      debugPrint('❌ [PlatformError] $error\n$stack');
      _logErrorToConsole(error.toString(), stack.toString());
      return true;
    };
  }

  static Exception mapDioException(DioException exception) {
    if (exception.type == DioExceptionType.connectionError ||
        exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.sendTimeout) {
      return const NetworkException('Connection timeout or network error. Please check your connection.');
    }

    if (exception.response?.statusCode == 400) {
      return ServerException('Bad request. Please check your input.');
    }
    if (exception.response?.statusCode == 401) {
      return ServerException('Unauthorized. Please login again.');
    }
    if (exception.response?.statusCode == 403) {
      return ServerException('Forbidden. You do not have access.');
    }
    if (exception.response?.statusCode == 404) {
      return ServerException('Resource not found.');
    }
    if (exception.response?.statusCode == 500) {
      return ServerException('Server error. Please try again later.');
    }
    if (exception.response?.statusCode != null) {
      return ServerException('Server error (${exception.response?.statusCode}). Please try again.');
    }

    return const AppException('An unexpected error occurred. Please try again.');
  }

  static Failure mapToFailure(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    }
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    }
    return UnknownFailure(exception.toString());
  }

  static void handleNetworkError(dynamic error) {
    String message = 'Network error occurred';

    if (error is NetworkException) {
      message = error.message;
    } else if (error is String) {
      message = error;
    }

    debugPrint('❌ [NetworkError] $message');
    _logErrorToConsole('Network Error', message);
    _showErrorSnackBar(
      title: 'Network Error',
      message: message,
      duration: const Duration(seconds: 4),
    );
  }

  static void handleValidationError(String fieldName, String message) {
    debugPrint('⚠️  [ValidationError] $fieldName: $message');
    _logErrorToConsole('Validation Error', '$fieldName: $message');
  }

  static void handleGenericError(Object error, StackTrace? stack) {
    debugPrint('❌ [Error] $error\n$stack');
    _logErrorToConsole(error.toString(), stack?.toString() ?? 'No stack trace');
    _showErrorSnackBar(
      title: 'Error',
      message: error.toString().length > 150
          ? 'An error occurred. Please try again.'
          : error.toString(),
    );
  }

  static void _showErrorSnackBar({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    final BuildContext? context = navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(message),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  static void _logErrorToConsole(String title, String message) {
    // Simple implementation - centralized error logging
    debugPrint('📁 [ERROR_LOG] $title\n   $message');
  }

  static String formatErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return error.message;
    }
    if (error is String) {
      return error.length > 200 ? 'An unexpected error occurred' : error;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
