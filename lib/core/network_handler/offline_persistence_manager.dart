import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/pending_action_model.dart';

/// Manages offline persistence of pending actions
class OfflinePersistenceManager {
  static const String _pendingActionsKey = 'pending_actions_queue';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const int maxPendingActions = 50; // Prevent unlimited storage growth

  final SharedPreferences _prefs;

  OfflinePersistenceManager(this._prefs);

  /// Save a pending action to local storage
  Future<bool> savePendingAction(PendingActionModel action) async {
    try {
      final List<PendingActionModel> existing = await getPendingActions();
      
      // Prevent exceeding max storage
      if (existing.length >= maxPendingActions) {
        debugPrint(
          '⚠️  [OfflinePersistence] Max pending actions reached ($maxPendingActions), discarding oldest',
        );
        existing.removeAt(0); // Remove oldest
      }

      existing.add(action);
      final List<String> jsonList =
          existing.map((PendingActionModel a) => jsonEncode(a.toJson())).toList();
      
      final bool success = await _prefs.setStringList(_pendingActionsKey, jsonList);
      debugPrint(
        '✅ [OfflinePersistence] Saved pending action: ${action.id} (Total: ${existing.length})',
      );
      return success;
    } catch (e) {
      debugPrint('❌ [OfflinePersistence] Error saving action: $e');
      return false;
    }
  }

  /// Get all pending actions
  Future<List<PendingActionModel>> getPendingActions() async {
    try {
      final List<String>? jsonList =
          _prefs.getStringList(_pendingActionsKey);
      if (jsonList == null || jsonList.isEmpty) {
        return <PendingActionModel>[];
      }

      return jsonList
          .map(
            (String json) => PendingActionModel.fromJson(
              Map<String, dynamic>.from(jsonDecode(json) as Map),
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('❌ [OfflinePersistence] Error retrieving actions: $e');
      return <PendingActionModel>[];
    }
  }

  /// Get pending actions for a specific application
  Future<List<PendingActionModel>> getPendingActionsForApp(
    String applicationId,
  ) async {
    final List<PendingActionModel> all = await getPendingActions();
    return all
        .where((PendingActionModel a) => a.applicationId == applicationId)
        .toList();
  }

  /// Mark a pending action as synced and remove it
  Future<bool> removePendingAction(String actionId) async {
    try {
      final List<PendingActionModel> existing = await getPendingActions();
      existing.removeWhere((PendingActionModel a) => a.id == actionId);
      final List<String> jsonList =
          existing.map((PendingActionModel a) => jsonEncode(a.toJson())).toList();
      
      final bool success = await _prefs.setStringList(_pendingActionsKey, jsonList);
      debugPrint(
        '✅ [OfflinePersistence] Removed synced action: $actionId (Remaining: ${existing.length})',
      );
      return success;
    } catch (e) {
      debugPrint('❌ [OfflinePersistence] Error removing action: $e');
      return false;
    }
  }

  /// Update retry count for a pending action
  Future<bool> incrementRetryCount(String actionId) async {
    try {
      final List<PendingActionModel> existing = await getPendingActions();
      final int index =
          existing.indexWhere((PendingActionModel a) => a.id == actionId);
      
      if (index == -1) {
        return false;
      }

      existing[index] = existing[index].copyWith(
        attemptCount: existing[index].attemptCount + 1,
      );
      
      final List<String> jsonList =
          existing.map((PendingActionModel a) => jsonEncode(a.toJson())).toList();
      return await _prefs.setStringList(_pendingActionsKey, jsonList);
    } catch (e) {
      debugPrint('❌ [OfflinePersistence] Error incrementing retry: $e');
      return false;
    }
  }

  /// Clear all pending actions
  Future<bool> clearPendingActions() async {
    try {
      debugPrint('🧹 [OfflinePersistence] Clearing all pending actions');
      return await _prefs.remove(_pendingActionsKey);
    } catch (e) {
      debugPrint('❌ [OfflinePersistence] Error clearing actions: $e');
      return false;
    }
  }

  /// Get last sync timestamp
  DateTime? getLastSyncTime() {
    try {
      final String? timestamp = _prefs.getString(_lastSyncKey);
      if (timestamp == null) {
        return null;
      }
      return DateTime.parse(timestamp);
    } catch (e) {
      debugPrint('⚠️  [OfflinePersistence] Error reading last sync time: $e');
      return null;
    }
  }

  /// Set last sync timestamp
  Future<bool> setLastSyncTime(DateTime time) async {
    try {
      return await _prefs.setString(_lastSyncKey, time.toIso8601String());
    } catch (e) {
      debugPrint('❌ [OfflinePersistence] Error setting last sync time: $e');
      return false;
    }
  }

  /// Check if device is currently online (based on pending actions)
  Future<bool> hasPendingActions() async {
    final List<PendingActionModel> pending = await getPendingActions();
    return pending.isNotEmpty;
  }

  /// Get count of pending actions
  Future<int> getPendingActionCount() async {
    final List<PendingActionModel> pending = await getPendingActions();
    return pending.length;
  }
}
