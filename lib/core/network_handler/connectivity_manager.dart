import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Manages network connectivity detection
class ConnectivityManager {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged => _connectivityStream;
  
  late final Stream<bool> _connectivityStream = _connectivity.onConnectivityChanged
      .map((ConnectivityResult result) {
        final bool isOnline = result != ConnectivityResult.none;
        debugPrint(
          isOnline
              ? '✅ [Connectivity] Device is ONLINE'
              : '❌ [Connectivity] Device is OFFLINE',
        );
        return isOnline;
      })
      .asBroadcastStream();

  /// Check current connectivity status
  Future<bool> isConnected() async {
    try {
      final ConnectivityResult result = await _connectivity.checkConnectivity();
      final bool connected = result != ConnectivityResult.none;
      debugPrint(
        '🔍 [Connectivity] Check result: ${connected ? 'ONLINE' : 'OFFLINE'}',
      );
      return connected;
    } catch (e) {
      debugPrint('❌ [Connectivity] Error checking connection: $e');
      // Assume online if we can't determine
      return true;
    }
  }

  /// Cleanup resources
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
