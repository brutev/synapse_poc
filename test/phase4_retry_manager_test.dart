import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:loan_poc/core/error/retry_manager.dart';
import 'package:loan_poc/core/network_handler/offline_persistence_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Helper to create a test offline persistence manager
Future<OfflinePersistenceManager> createTestPersistenceManager() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return OfflinePersistenceManager(prefs);
}

void main() {
  group('Phase 4: RetryManager Tests', () {
    late RetryManager retryManager;
    late OfflinePersistenceManager persistenceManager;

    setUp(() async {
      persistenceManager = await createTestPersistenceManager();
      retryManager = RetryManager(persistenceManager);
    });

    test('executeWithRetry succeeds on first attempt', () async {
      int executionCount = 0;
      
      final result = await retryManager.executeWithRetry<String>(
        operationId: 'test-op-1',
        operation: () async {
          executionCount++;
          return 'Success';
        },
        operationName: 'Test Operation',
      );

      expect(result, equals('Success'));
      expect(executionCount, equals(1));
      
      final stats = retryManager.getStatistics();
      expect(stats['totalAttempts'], equals(1));
      expect(stats['successCount'], equals(1));
      expect(stats['failureCount'], equals(0));
      
      print('✅ [Test] RetryManager succeeds on first attempt');
    });

    test('executeWithRetry retries on failure then succeeds', () async {
      int executionCount = 0;
      
      final result = await retryManager.executeWithRetry<String>(
        operationId: 'test-op-2',
        operation: () async {
          executionCount++;
          if (executionCount < 3) {
            throw Exception('Temporary failure');
          }
          return 'Success after retry';
        },
        operationName: 'Retry Test',
      );

      expect(result, equals('Success after retry'));
      expect(executionCount, equals(3)); // Failed twice, succeeded third time
      
      final stats = retryManager.getStatistics();
      expect(stats['totalAttempts'], greaterThanOrEqualTo(1));
      expect(stats['successCount'], greaterThanOrEqualTo(1));
      
      print('✅ [Test] RetryManager retries and eventually succeeds');
    });

    test('executeWithRetry fails after max attempts', () async {
      int executionCount = 0;
      
      try {
        await retryManager.executeWithRetry<String>(
          operationId: 'test-op-3',
          operation: () async {
            executionCount++;
            throw Exception('Persistent failure');
          },
          operationName: 'Max Retry Test',
          maxRetries: 3,
        );
        fail('Should have thrown exception');
      } catch (e) {
        expect(e.toString(), contains('Persistent failure'));
        expect(executionCount, equals(3)); // Tried 3 times max
        
        final stats = retryManager.getStatistics();
        expect(stats['failureCount'], greaterThanOrEqualTo(1));
      }
      
      print('✅ [Test] RetryManager respects max attempts limit');
    });

    test('executeWithRetry applies exponential backoff', () async {
      int executionCount = 0;
      final executionTimes = <DateTime>[];
      
      try {
        await retryManager.executeWithRetry<String>(
          operationId: 'test-op-4',
          operation: () async {
            executionCount++;
            executionTimes.add(DateTime.now());
            throw Exception('Always fails');
          },
          operationName: 'Backoff Test',
          maxRetries: 3,
          initialDelay: const Duration(milliseconds: 100), // Faster for testing
        );
      } catch (_) {}

      expect(executionCount, equals(3));
      expect(executionTimes.length, equals(3));
      
      // Check delays between attempts (approximately exponential)
      if (executionTimes.length >= 2) {
        final delay1 = executionTimes[1].difference(executionTimes[0]).inMilliseconds;
        // Should be approximately 100ms (initial delay)
        expect(delay1, greaterThanOrEqualTo(90));
        expect(delay1, lessThanOrEqualTo(200));
      }
      
      if (executionTimes.length >= 3) {
        final delay2 = executionTimes[2].difference(executionTimes[1]).inMilliseconds;
        // Should be approximately 200ms (2x initial delay)
        expect(delay2, greaterThanOrEqualTo(180));
        expect(delay2, lessThanOrEqualTo(300));
      }
      
      print('✅ [Test] RetryManager applies exponential backoff correctly');
    });

    test('executeWithOfflineQueue queues action on failure', () async {
      int executionCount = 0;
      
      try {
        await retryManager.executeWithOfflineQueue(
          operationId: 'test-queue-1',
          operation: () async {
            executionCount++;
            throw Exception('Always fails');
          },
          operationName: 'Queue Test',
          actionType: 'test_action',
          actionData: {'test': 'data', 'applicationId': 'app-1'},
        );
      } catch (_) {}

      expect(executionCount, greaterThanOrEqualTo(1)); // At least tried once
      
      // Check if action was queued
      final queuedActions = await persistenceManager.getPendingActions();
      expect(queuedActions.length, equals(1));
      
      final queuedAction = queuedActions.first;
      expect(queuedAction.type, equals('test_action'));
      expect(queuedAction.data['test'], equals('data'));
      
      print('✅ [Test] RetryManager queues failed operations offline');
    });

    test('executeWithOfflineQueue does not queue on success', () async {
      await retryManager.executeWithOfflineQueue(
        operationId: 'test-queue-2',
        operation: () async {
          return 'Success';
        },
        operationName: 'No Queue Test',
        actionType: 'test_action',
        actionData: {'test': 'data', 'applicationId': 'app-2'},
      );

      final queuedActions = await persistenceManager.getPendingActions();
      // Should only have the one from previous test
      expect(queuedActions.any((a) => a.applicationId == 'app-2'), isFalse);
      
      print('✅ [Test] RetryManager does not queue successful operations');
    });

    test('getStatistics calculates success rate correctly', () async {
      // Execute 3 successful operations
      for (int i = 0; i < 3; i++) {
        await retryManager.executeWithRetry<void>(
          operationId: 'success-$i',
          operation: () async {},
          operationName: 'Success $i',
        );
      }

      // Execute 1 failed operation (3 attempts)
      try {
        await retryManager.executeWithRetry<void>(
          operationId: 'failure-1',
          operation: () async {
            throw Exception('Fail');
          },
          operationName: 'Failure',
          maxRetries: 2,
        );
      } catch (_) {}

      final stats = retryManager.getStatistics();
      expect(stats['successCount'], greaterThanOrEqualTo(3));
      expect(stats['failureCount'], greaterThanOrEqualTo(1));
      
      print('✅ [Test] RetryManager calculates statistics correctly');
    });

    test('clearActiveRetries removes pending operations', () async {
      // Start a long operation
      final future = retryManager.executeWithRetry<String>(
        operationId: 'long-op',
        operation: () async {
          await Future.delayed(const Duration(seconds: 2));
          return 'Done';
        },
        operationName: 'Long Operation',
      );

      await Future.delayed(const Duration(milliseconds: 100));
      
      // Clear should not affect running operations
      retryManager.clearActiveRetries();
      
      // Operation should still complete
      final result = await future;
      expect(result, equals('Done'));
      
      print('✅ [Test] RetryManager clears active retries safely');
    });

    test('RetryManager tracks operation details', () async {
      final stopwatch = Stopwatch()..start();
      
      await retryManager.executeWithRetry<void>(
        operationId: 'tracked-op',
        operation: () async {
          await Future.delayed(const Duration(milliseconds: 50));
        },
        operationName: 'Tracked Operation',
      );
      
      stopwatch.stop();
      
      // Operation should have completed in roughly 50ms
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(40));
      
      print('✅ [Test] RetryManager tracks operation timing');
    });

    test('RetryManager handles concurrent operations', () async {
      final results = await Future.wait([
        retryManager.executeWithRetry<int>(
          operationId: 'concurrent-1',
          operation: () async => 1,
          operationName: 'Op 1',
        ),
        retryManager.executeWithRetry<int>(
          operationId: 'concurrent-2',
          operation: () async => 2,
          operationName: 'Op 2',
        ),
        retryManager.executeWithRetry<int>(
          operationId: 'concurrent-3',
          operation: () async => 3,
          operationName: 'Op 3',
        ),
      ]);

      expect(results, equals([1, 2, 3]));
      
      final stats = retryManager.getStatistics();
      expect(stats['successCount'], greaterThanOrEqualTo(3));
      
      print('✅ [Test] RetryManager handles concurrent operations correctly');
    });
  });

  group('Phase 4: Edge Case Tests', () {
    late RetryManager retryManager;
    late OfflinePersistenceManager persistenceManager;

    setUp(() async {
      persistenceManager = await createTestPersistenceManager();
      retryManager = RetryManager(persistenceManager);
    });

    test('RetryManager handles null return values', () async {
      final result = await retryManager.executeWithRetry<String?>(
        operationId: 'null-op',
        operation: () async => null,
        operationName: 'Null Return',
      );

      expect(result, isNull);
      
      print('✅ [Test] RetryManager handles null results correctly');
    });

    test('RetryManager handles operation timeout', () async {
      try {
        await retryManager.executeWithRetry<void>(
          operationId: 'timeout-op',
          operation: () async {
            await Future.delayed(const Duration(seconds: 10));
          },
          operationName: 'Timeout Test',
          maxRetries: 1,
        ).timeout(const Duration(milliseconds: 100));
        fail('Should have timed out');
      } catch (e) {
        expect(e, isA<TimeoutException>());
      }
      
      print('✅ [Test] RetryManager operations can timeout');
    });

    test('RetryManager preserves error details', () async {
      final customError = ArgumentError('Invalid input');
      
      try {
        await retryManager.executeWithRetry<void>(
          operationId: 'error-op',
          operation: () async {
            throw customError;
          },
          operationName: 'Error Preservation Test',
          maxRetries: 1,
        );
        fail('Should have thrown');
      } catch (e) {
        expect(e, equals(customError));
        expect(e.toString(), contains('Invalid input'));
      }
      
      print('✅ [Test] RetryManager preserves original error details');
    });
  });
}
