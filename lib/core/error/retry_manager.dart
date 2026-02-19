import 'dart:async';

import 'package:flutter/foundation.dart';
import '../network_handler/offline_persistence_manager.dart';
import '../network_handler/models/pending_action_model.dart';

/// Manages retry operations with exponential backoff
class RetryManager extends ChangeNotifier {
  static const _maxRetries = 3;
  static const _initialDelayMs = 500; // 500ms
  static const _backoffMultiplier = 2;

  final OfflinePersistenceManager _persistenceManager;

  int _totalAttempts = 0;
  int _successCount = 0;
  int _failureCount = 0;

  Map<String, RetryOperation> _activeRetries = {};

  int get totalAttempts => _totalAttempts;
  int get successCount => _successCount;
  int get failureCount => _failureCount;
  Map<String, RetryOperation> get activeRetries => _activeRetries;

  RetryManager(this._persistenceManager);

  /// Execute operation with retry logic
  Future<T> executeWithRetry<T>({
    required String operationId,
    required Future<T> Function() operation,
    required String operationName,
    Duration? initialDelay,
    int? maxRetries,
  }) async {
    final delay = initialDelay ?? const Duration(milliseconds: _initialDelayMs);
    final maxAttempts = maxRetries ?? _maxRetries;
    int attemptCount = 0;
    dynamic lastError;
    StackTrace? lastStackTrace;

    _totalAttempts++;

    final retryOp = RetryOperation(
      id: operationId,
      name: operationName,
      startTime: DateTime.now(),
      maxRetries: maxAttempts,
    );
    _activeRetries[operationId] = retryOp;
    notifyListeners();

    while (attemptCount < maxAttempts) {
      try {
        attemptCount++;
        retryOp.currentAttempt = attemptCount;
        debugPrint(
          '🔄 [RetryManager] Attempt $attemptCount/$maxAttempts: $operationName',
        );

        final result = await operation();

        _successCount++;
        retryOp.status = 'success';
        retryOp.endTime = DateTime.now();
        debugPrint(
          '✅ [RetryManager] Success: $operationName (${retryOp.endTime!.difference(retryOp.startTime).inMilliseconds}ms)',
        );

        _activeRetries.remove(operationId);
        notifyListeners();
        return result;
      } catch (e, stackTrace) {
        lastError = e;
        lastStackTrace = stackTrace;

        if (attemptCount < maxAttempts) {
          final backoffMs = _initialDelayMs * (_backoffMultiplier ^ (attemptCount - 1));
          debugPrint(
            '⏳ [RetryManager] Retry after ${backoffMs}ms (Attempt $attemptCount failed): $e',
          );
          await Future.delayed(Duration(milliseconds: backoffMs));
        } else {
          _failureCount++;
          retryOp.status = 'failed';
          retryOp.endTime = DateTime.now();
          retryOp.error = e.toString();
          debugPrint(
            '❌ [RetryManager] Failed after $attemptCount attempts: $operationName\nError: $e\nStackTrace: $stackTrace',
          );

          _activeRetries.remove(operationId);
          notifyListeners();
          rethrow;
        }
      }
    }

    // Should not reach here, but just in case
    _failureCount++;
    _activeRetries.remove(operationId);
    notifyListeners();
    throw lastError ?? Exception('Unknown error after $attemptCount attempts');
  }

  /// Execute operation and queue for offline sync if it fails
  Future<T> executeWithOfflineQueue<T>({
    required String operationId,
    required Future<T> Function() operation,
    required String operationName,
    required String actionType,
    required Map<String, dynamic> actionData,
  }) async {
    try {
      return await executeWithRetry(
        operationId: operationId,
        operation: operation,
        operationName: operationName,
      );
    } catch (e) {
      debugPrint(
        '📦 [RetryManager] Queuing for offline sync: $operationName',
      );
      // Store in offline queue for later sync
      final actionModel = PendingActionModel(
        id: operationId,
        type: actionType,
        applicationId: actionData['applicationId'] ?? operationId,
        data: actionData,
        createdAt: DateTime.now(),
      );
      await _persistenceManager.savePendingAction(actionModel);
      rethrow;
    }
  }

  /// Get retry progress for an operation
  RetryOperation? getRetryProgress(String operationId) {
    return _activeRetries[operationId];
  }

  /// Clear all active retries
  void clearActiveRetries() {
    _activeRetries.clear();
    notifyListeners();
  }

  /// Reset statistics
  void resetStatistics() {
    _totalAttempts = 0;
    _successCount = 0;
    _failureCount = 0;
    notifyListeners();
  }

  /// Get retry statistics
  Map<String, dynamic> getStatistics() {
    final successRate =
        _totalAttempts > 0 ? (_successCount / _totalAttempts * 100) : 0.0;
    return {
      'total_attempts': _totalAttempts,
      'success_count': _successCount,
      'failure_count': _failureCount,
      'success_rate': successRate.toStringAsFixed(1),
      'active_retries': _activeRetries.length,
    };
  }

  @override
  void dispose() {
    _activeRetries.clear();
    super.dispose();
  }
}

/// Model representing a single retry operation
class RetryOperation {
  final String id;
  final String name;
  final DateTime startTime;
  final int maxRetries;

  int currentAttempt = 0;
  String status = 'pending'; // pending, retrying, success, failed
  DateTime? endTime;
  String? error;

  RetryOperation({
    required this.id,
    required this.name,
    required this.startTime,
    required this.maxRetries,
  });

  Duration get elapsed {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  bool get isActive => endTime == null;
  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'current_attempt': currentAttempt,
        'max_retries': maxRetries,
        'status': status,
        'elapsed_ms': elapsed.inMilliseconds,
        'error': error,
      };
}

// Helper extension for easy retry management
// Usage: await someFuture.withRetry(...)
// Disabled due to context requirements - use RetryManager.executeWithRetry instead
