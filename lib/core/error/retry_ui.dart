import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef AsyncCallback = Future<void> Function();

/// Retry button for failed operations
class RetryButton extends StatefulWidget {
  final AsyncCallback onRetry;
  final String? label;
  final IconData icon;
  final double? width;
  final double height;
  final VoidCallback? onSuccess;

  const RetryButton({
    required this.onRetry,
    this.label,
    this.icon = Icons.refresh,
    this.width,
    this.height = 44,
    this.onSuccess,
    super.key,
  });

  @override
  State<RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<RetryButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleRetry,
        icon: _isLoading
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
            : Icon(widget.icon),
        label: Text(
          _isLoading ? 'Retrying...' : (widget.label ?? 'Retry'),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Future<void> _handleRetry() async {
    setState(() => _isLoading = true);
    try {
      await widget.onRetry();
      widget.onSuccess?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Retry successful!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [RetryButton] Retry failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Retry failed: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Retry dialog for user confirmation and retry attempts
class RetryDialog extends StatefulWidget {
  final String title;
  final String message;
  final String actionLabel;
  final AsyncCallback onRetry;
  final bool showAttemptCount;

  const RetryDialog({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onRetry,
    this.showAttemptCount = true,
    super.key,
  });

  @override
  State<RetryDialog> createState() => _RetryDialogState();
}

class _RetryDialogState extends State<RetryDialog> {
  bool _isRetrying = false;
  int _attemptCount = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.error_outline,
        color: Colors.orange.shade600,
        size: 32,
      ),
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (widget.showAttemptCount) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  'Attempt $_attemptCount of 3',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isRetrying ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isRetrying ? null : _handleRetry,
          icon: _isRetrying
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ),
                  ),
                )
              : const Icon(Icons.refresh),
          label: Text(_isRetrying ? 'Retrying...' : widget.actionLabel),
        ),
      ],
    );
  }

  Future<void> _handleRetry() async {
    setState(() => _isRetrying = true);
    try {
      await widget.onRetry();
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      debugPrint('❌ [RetryDialog] Retry failed: $e');
      if (mounted) {
        setState(() {
          _isRetrying = false;
          if (_attemptCount < 3) {
            _attemptCount++;
          } else {
            // Max attempts reached
            Navigator.pop(context, false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  '❌ Max retry attempts reached. Please try again later.',
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      }
    }
  }
}

/// Retry snackbar for displaying retry options inline
class RetrySnackBar extends SnackBar {
  RetrySnackBar({
    required String message,
    required AsyncCallback onRetry,
    String actionLabel = 'Retry',
    super.key,
  }) : super(
          content: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          action: SnackBarAction(
            label: actionLabel,
            onPressed: onRetry,
            textColor: Colors.white,
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 7),
        );
}

/// Offline retry notification with offline queue info
class OfflineRetryNotification extends StatelessWidget {
  final String message;
  final int pendingActionCount;
  final VoidCallback? onViewQueue;
  final VoidCallback? onDismiss;

  const OfflineRetryNotification({
    required this.message,
    required this.pendingActionCount,
    this.onViewQueue,
    this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.amber.shade50,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          border: Border(
            bottom: BorderSide(color: Colors.amber.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.amber.shade700, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    '$pendingActionCount action${pendingActionCount != 1 ? 's' : ''} pending',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade700,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
            if (onViewQueue != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onViewQueue,
                child: const Text('View'),
              ),
            ],
            if (onDismiss != null) ...[
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onDismiss,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Retry statistics display (for debugging)
class RetryStatistics extends StatelessWidget {
  final int totalAttempts;
  final int successCount;
  final int failureCount;

  const RetryStatistics({
    required this.totalAttempts,
    required this.successCount,
    required this.failureCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final successRate =
        totalAttempts > 0 ? (successCount / totalAttempts * 100).toStringAsFixed(1) : '0';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Retry Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  label: 'Total',
                  value: totalAttempts.toString(),
                  color: Colors.blue,
                ),
                _StatItem(
                  label: 'Success',
                  value: successCount.toString(),
                  color: Colors.green,
                ),
                _StatItem(
                  label: 'Failed',
                  value: failureCount.toString(),
                  color: Colors.red,
                ),
                _StatItem(
                  label: 'Success Rate',
                  value: '$successRate%',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}
