import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef AsyncCallback = Future<void> Function();

/// Error boundary widget that catches errors in the widget tree
/// and displays a graceful error UI with retry option
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final VoidCallback? onRetry;
  final String? title;
  final String? subtitle;

  const ErrorBoundary({
    required this.child,
    this.onRetry,
    this.title,
    this.subtitle,
    super.key,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  late ErrorBoundaryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ErrorBoundaryController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundaryScope(
      controller: _controller,
      child: _ErrorBoundaryWidget(
        child: widget.child,
        controller: _controller,
        onRetry: widget.onRetry,
        title: widget.title,
        subtitle: widget.subtitle,
      ),
    );
  }
}

class _ErrorBoundaryWidget extends StatefulWidget {
  final Widget child;
  final ErrorBoundaryController controller;
  final VoidCallback? onRetry;
  final String? title;
  final String? subtitle;

  const _ErrorBoundaryWidget({
    required this.child,
    required this.controller,
    this.onRetry,
    this.title,
    this.subtitle,
  });

  @override
  State<_ErrorBoundaryWidget> createState() => _ErrorBoundaryWidgetState();
}

class _ErrorBoundaryWidgetState extends State<_ErrorBoundaryWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onErrorStateChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onErrorStateChange);
    super.dispose();
  }

  void _onErrorStateChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.hasError) {
      return _ErrorDisplay(
        error: widget.controller.error ?? 'Unknown error',
        stackTrace: widget.controller.stackTrace,
        onRetry: _handleRetry,
        title: widget.title ?? 'Oops! Something went wrong',
        subtitle: widget.subtitle,
      );
    }

    return widget.child;
  }

  Future<void> _handleRetry() async {
    widget.controller.clearError();
    widget.onRetry?.call();
  }
}

/// Error display UI with retry button
class _ErrorDisplay extends StatefulWidget {
  final Object error;
  final StackTrace? stackTrace;
  final AsyncCallback onRetry;
  final String title;
  final String? subtitle;

  const _ErrorDisplay({
    required this.error,
    required this.stackTrace,
    required this.onRetry,
    required this.title,
    this.subtitle,
  });

  @override
  State<_ErrorDisplay> createState() => _ErrorDisplayState();
}

class _ErrorDisplayState extends State<_ErrorDisplay> {
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Error icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 40,
                      color: Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  if (widget.subtitle != null) ...[
                    Text(
                      widget.subtitle!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Error message (in debug only)
                  if (kDebugMode) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Error Details:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.error.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                  color: Colors.grey.shade600,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Retry button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isRetrying ? null : _handleRetry,
                      icon: _isRetrying
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Theme.of(context).primaryColor.withOpacity(0.8),
                                ),
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(
                        _isRetrying ? 'Retrying...' : 'Retry',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Home button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Go to Home'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRetry() async {
    setState(() => _isRetrying = true);
    try {
      await widget.onRetry();
    } catch (e) {
      debugPrint('❌ [ErrorBoundary] Retry failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Retry failed. Please try again.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }
}

/// Controller for managing error state
class ErrorBoundaryController extends ChangeNotifier {
  Object? _error;
  StackTrace? _stackTrace;
  bool _hasError = false;

  Object? get error => _error;
  StackTrace? get stackTrace => _stackTrace;
  bool get hasError => _hasError;

  void captureError(Object error, StackTrace stackTrace) {
    _error = error;
    _stackTrace = stackTrace;
    _hasError = true;
    debugPrint('❌ [ErrorBoundary] Error captured: $error\n$stackTrace');
    notifyListeners();
  }

  void clearError() {
    _error = null;
    _stackTrace = null;
    _hasError = false;
    notifyListeners();
  }

  @override
  void dispose() {
    clearError();
    super.dispose();
  }
}

/// Scope to provide error boundary context
class ErrorBoundaryScope extends InheritedWidget {
  final ErrorBoundaryController controller;

  const ErrorBoundaryScope({
    required this.controller,
    required super.child,
    super.key,
  });

  static ErrorBoundaryController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ErrorBoundaryScope>();
    assert(scope != null, 'ErrorBoundaryScope not found in context');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(ErrorBoundaryScope oldWidget) =>
      controller != oldWidget.controller;
}
