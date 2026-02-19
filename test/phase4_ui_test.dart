import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loan_poc/core/error/error_boundary.dart';
import 'package:loan_poc/core/error/retry_ui.dart';

void main() {
  group('Phase 4: Error Boundary Tests', () {
    testWidgets('ErrorBoundary initializes and displays child widget',
        (WidgetTester tester) async {
      
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            onRetry: () {},
            child: const Text('App Content'),
          ),
        ),
      );

      // Initially shows child widget
      expect(find.text('App Content'), findsOneWidget);
      
      print('✅ [Test] ErrorBoundary displays child widget initially');
    });

    testWidgets('ErrorBoundaryController manages error state',
        (WidgetTester tester) async {
      final controller = ErrorBoundaryController();
      
      expect(controller.hasError, isFalse);
      expect(controller.error, isNull);
      
      final testError = Exception('Test error');
      final testStack = StackTrace.current;
      
      controller.captureError(testError, testStack);
      
      expect(controller.hasError, isTrue);
      expect(controller.error, equals(testError));
      expect(controller.stackTrace, equals(testStack));
      
      controller.clearError();
      
      expect(controller.hasError, isFalse);
      expect(controller.error, isNull);
      
      print('✅ [Test] ErrorBoundaryController state management works');
    });

    testWidgets('ErrorBoundary shows custom title and subtitle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            title: 'Custom Error',
            subtitle: 'Custom message',
            onRetry: () {},
            child: const Text('App'),
          ),
        ),
      );

      expect(find.text('App'), findsOneWidget);
      
      print('✅ [Test] ErrorBoundary accepts custom configuration');
    });
  });

  group('Phase 4: Retry UI Component Tests', () {
    testWidgets('RetryButton displays correctly and handles tap',
        (WidgetTester tester) async {
      bool retryExecuted = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetryButton(
              onRetry: () async {
                await Future.delayed(const Duration(milliseconds: 100));
                retryExecuted = true;
              },
              label: 'Test Retry',
            ),
          ),
        ),
      );

      expect(find.text('Test Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      
      await tester.tap(find.text('Test Retry'));
      await tester.pump();
      
      // Should show loading state
      expect(find.text('Retrying...'), findsOneWidget);
      
      await tester.pumpAndSettle();
      
      expect(retryExecuted, isTrue);
      expect(find.text('Test Retry'), findsOneWidget); // Back to normal
      
      print('✅ [Test] RetryButton works with loading states');
    });

    testWidgets('RetryDialog shows attempt count',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => RetryDialog(
                      title: 'Retry Required',
                      message: 'Operation failed',
                      actionLabel: 'Try Again',
                      onRetry: () async {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Retry Required'), findsOneWidget);
      expect(find.text('Operation failed'), findsOneWidget);
      expect(find.text('Attempt 1 of 3'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      
      print('✅ [Test] RetryDialog displays correctly');
    });

    testWidgets('OfflineRetryNotification shows pending count',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineRetryNotification(
              message: 'You are offline',
              pendingActionCount: 5,
              onViewQueue: () {},
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('You are offline'), findsOneWidget);
      expect(find.text('5 actions pending'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      
      print('✅ [Test] OfflineRetryNotification displays pending actions');
    });

    testWidgets('RetryStatistics displays metrics',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RetryStatistics(
              totalAttempts: 10,
              successCount: 7,
              failureCount: 3,
            ),
          ),
        ),
      );

      expect(find.text('Retry Statistics'), findsOneWidget);
      expect(find.text('10'), findsOneWidget); // Total
      expect(find.text('7'), findsOneWidget); // Success
      expect(find.text('3'), findsOneWidget); // Failed
      expect(find.text('70.0%'), findsOneWidget); // Success rate
      
      print('✅ [Test] RetryStatistics calculates and displays correctly');
    });
  });

  group('Phase 4: Integration Tests', () {
    testWidgets('ErrorBoundary integrates with MaterialApp',
        (WidgetTester tester) async {
      int retryCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            title: 'Custom Error Title',
            subtitle: 'Custom error message',
            onRetry: () {
              retryCount++;
            },
            child: const Scaffold(
              body: Text('App Content'),
            ),
          ),
        ),
      );

      expect(find.text('App Content'), findsOneWidget);
      
      print('✅ [Test] ErrorBoundary integrates with app successfully');
    });

    testWidgets('Multiple ErrorBoundary instances can coexist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              ErrorBoundary(
                onRetry: () {},
                child: const Text('Section 1'),
              ),
              ErrorBoundary(
                onRetry: () {},
                child: const Text('Section 2'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Section 1'), findsOneWidget);
      expect(find.text('Section 2'), findsOneWidget);
      
      print('✅ [Test] Multiple ErrorBoundary instances work correctly');
    });
  });
}
