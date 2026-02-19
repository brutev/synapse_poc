import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/error/error_boundary.dart';
import 'core/error/error_handler.dart';
import 'core/navigation/app_navigator.dart';
import 'core/network_handler/connectivity_manager.dart';
import 'core/network_handler/sync_manager.dart';
import 'core/shared_services/presentation/cubit/application_flow_cubit.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  // Configure image cache limits
  imageCache.maximumSize = 100; // 100 MB total
  imageCache.maximumSizeBytes = 100 * 1024 * 1024; // 100 MB

  // Setup global error handlers
  ErrorHandler.setupGlobalErrorHandlers();

  runApp(const LoanPocApp());
}

class LoanPocApp extends StatefulWidget {
  const LoanPocApp({super.key});

  @override
  State<LoanPocApp> createState() => _LoanPocAppState();
}

class _LoanPocAppState extends State<LoanPocApp> {
  late SyncManager? _syncManager;

  @override
  void initState() {
    super.initState();
    // Start listening for connectivity changes and sync pending actions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _syncManager = sl<SyncManager>();
        _syncManager?.startSyncListener();
        debugPrint('🔄 [App] Sync manager started');
      } catch (e) {
        debugPrint('⚠️  [App] Warning: Could not start sync manager: $e');
        // App continues to work without sync manager
      }
    });
  }

  @override
  void dispose() {
    // Cleanup sync manager
    try {
      _syncManager?.dispose();
    } catch (e) {
      debugPrint('⚠️  [App] Error disposing sync manager: $e');
    }
    try {
      sl<ConnectivityManager>().dispose();
    } catch (e) {
      debugPrint('⚠️  [App] Error disposing connectivity manager: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = AppNavigator.createRouter();

    return ErrorBoundary(
      onRetry: () async {
        // Refresh app state on retry
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: BlocProvider<ApplicationFlowCubit>.value(
        value: sl<ApplicationFlowCubit>(),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: AppConfig.appName,
          theme: AppTheme.light(),
          routerConfig: router,
          scaffoldMessengerKey: _scaffoldKey,
        ),
      ),
    );
  }

  static final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
}
