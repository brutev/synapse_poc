import 'dart:async';
import 'package:flutter/foundation.dart';

import 'connectivity_manager.dart';
import 'models/pending_action_model.dart';
import 'network_api_service.dart';
import 'offline_persistence_manager.dart';

/// Handles syncing of pending actions when device comes online
class SyncManager {
  SyncManager({
    required this.connectivityManager,
    required this.persistenceManager,
    required this.networkService,
  });

  final ConnectivityManager connectivityManager;
  final OfflinePersistenceManager persistenceManager;
  final NetworkApiService networkService;

  StreamSubscription? _connectivitySubscription;
  Timer? _retryTimer;
  bool _isSyncing = false;

  /// Start listening for connectivity changes
  void startSyncListener() {
    debugPrint('🔄 [SyncManager] Starting sync listener');

    _connectivitySubscription =
        connectivityManager.onConnectivityChanged.listen(
      (bool isOnline) async {
        if (isOnline) {
          debugPrint('🔄 [SyncManager] Device came ONLINE, attempting sync...');
          await syncPendingActions();
        } else {
          debugPrint('⏸️  [SyncManager] Device is OFFLINE, pausing sync');
          _retryTimer?.cancel();
        }
      },
    );
  }

  /// Sync all pending actions
  Future<void> syncPendingActions() async {
    if (_isSyncing) {
      debugPrint('⏳ [SyncManager] Sync already in progress, skipping');
      return;
    }

    _isSyncing = true;

    try {
      final List<PendingActionModel> pending =
          await persistenceManager.getPendingActions();

      if (pending.isEmpty) {
        debugPrint('✅ [SyncManager] No pending actions to sync');
        _isSyncing = false;
        return;
      }

      debugPrint('🔄 [SyncManager] Syncing ${pending.length} pending actions...');

      int successCount = 0;
      int failureCount = 0;

      for (final PendingActionModel action in pending) {
        try {
          await _syncAction(action);
          await persistenceManager.removePendingAction(action.id);
          successCount++;
          debugPrint(
            '✅ [SyncManager] Synced action: ${action.id} (${action.type})',
          );
        } catch (e) {
          failureCount++;
          await persistenceManager.incrementRetryCount(action.id);
          debugPrint(
            '❌ [SyncManager] Failed to sync action ${action.id}: $e',
          );
          // Continue with next action
        }
      }

      debugPrint(
        '📊 [SyncManager] Sync complete: $successCount succeeded, $failureCount failed',
      );

      if (failureCount > 0) {
        // Schedule retry after delay
        _scheduleRetry();
      } else {
        await persistenceManager.setLastSyncTime(DateTime.now());
      }
    } catch (e) {
      debugPrint('❌ [SyncManager] Error during sync: $e');
      _scheduleRetry();
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a single action
  Future<void> _syncAction(PendingActionModel action) async {
    switch (action.type) {
      case 'save_draft':
        await _syncSaveDraft(action);
        break;
      case 'execute_action':
        await _syncExecuteAction(action);
        break;
      case 'submit':
        await _syncSubmit(action);
        break;
      default:
        throw Exception('Unknown action type: ${action.type}');
    }
  }

  Future<void> _syncSaveDraft(PendingActionModel action) async {
    final String applicationId = action.applicationId;
    final Map<String, dynamic> data = action.data;

    await networkService.post(
      '/save_draft',
      body: <String, dynamic>{
        'applicationId': applicationId,
        'sectionId': data['sectionId'],
        'data': data['data'],
      },
    );
  }

  Future<void> _syncExecuteAction(PendingActionModel action) async {
    final String applicationId = action.applicationId;
    final Map<String, dynamic> data = action.data;

    await networkService.post(
      '/action',
      body: <String, dynamic>{
        'applicationId': applicationId,
        'actionId': data['actionId'],
        'payload': data['payload'],
      },
    );
  }

  Future<void> _syncSubmit(PendingActionModel action) async {
    final String applicationId = action.applicationId;

    await networkService.post(
      '/submit',
      body: <String, dynamic>{
        'applicationId': applicationId,
      },
    );
  }

  /// Schedule a retry after delay
  void _scheduleRetry({Duration delay = const Duration(seconds: 30)}) {
    debugPrint('⏳ [SyncManager] Scheduling retry in ${delay.inSeconds}s...');
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () async {
      final bool isOnline = await connectivityManager.isConnected();
      if (isOnline) {
        await syncPendingActions();
      }
    });
  }

  /// Cleanup resources
  void dispose() {
    debugPrint('🧹 [SyncManager] Disposing...');
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
  }
}
