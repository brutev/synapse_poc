import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/form_engine/data/datasources/form_engine_local_datasource.dart';
import '../components/form_engine/data/repositories/form_engine_repository_impl.dart';
import '../components/form_engine/domain/repositories/form_engine_repository.dart';
import '../components/form_engine/domain/usecases/load_draft_usecase.dart';
import '../components/form_engine/domain/usecases/load_tiles_usecase.dart';
import '../components/form_engine/domain/usecases/save_draft_usecase.dart';
import '../components/form_engine/presentation/cubit/form_engine_cubit.dart';
import '../components/static_form/data/picklist_cache_service.dart';
import '../components/static_form/domain/draft_conflict_resolver.dart';
import '../components/static_form/domain/field_state_mapper.dart';
import '../components/static_form/presentation/cubit/static_module_cubit.dart';
import '../network_handler/base_api_service.dart';
import '../navigation/app_navigator.dart';
import '../network_handler/network_api_service.dart';
import '../network_handler/connectivity_manager.dart';
import '../network_handler/offline_persistence_manager.dart';
import '../network_handler/sync_manager.dart';
import '../error/retry_manager.dart';
import '../services/frame_performance_service.dart';
import '../shared_services/data/datasources/los_remote_datasource.dart';
import '../shared_services/data/repositories/los_repository_impl.dart';
import '../shared_services/domain/repositories/los_repository.dart';
import '../shared_services/domain/usecases/create_los_application_usecase.dart';
import '../shared_services/domain/usecases/evaluate_los_usecase.dart';
import '../shared_services/domain/usecases/execute_los_action_usecase.dart';
import '../shared_services/domain/usecases/save_los_draft_usecase.dart';
import '../shared_services/domain/usecases/submit_los_usecase.dart';
import '../shared_services/presentation/cubit/application_flow_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // Network and connectivity
  sl.registerLazySingleton<NetworkApiService>(NetworkApiService.new);
  sl.registerLazySingleton<BaseApiService>(() => sl<NetworkApiService>());
  sl.registerLazySingleton<ConnectivityManager>(ConnectivityManager.new);

  // Offline persistence - must be initialized before SyncManager
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerLazySingleton<OfflinePersistenceManager>(
    () => OfflinePersistenceManager(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<PicklistCacheService>(
    () => PicklistCacheService(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<DraftConflictResolver>(DraftConflictResolver.new);
  sl.registerLazySingleton<FieldStateMapper>(FieldStateMapper.new);

  // Sync manager - register lazily, will be initialized on demand
  sl.registerLazySingleton<SyncManager>(
    () => SyncManager(
      connectivityManager: sl<ConnectivityManager>(),
      persistenceManager: sl<OfflinePersistenceManager>(),
      networkService: sl<NetworkApiService>(),
    ),
  );

  // Retry manager for handling operation retries
  sl.registerLazySingleton<RetryManager>(
    () => RetryManager(sl<OfflinePersistenceManager>()),
  );

  sl.registerLazySingleton(AppNavigator.createRouter);
  sl.registerLazySingleton<FormEngineLocalDataSource>(
    FormEngineLocalDataSourceImpl.new,
  );
  sl.registerLazySingleton<FormEngineRepository>(
    () => FormEngineRepositoryImpl(sl<FormEngineLocalDataSource>()),
  );
  sl.registerLazySingleton<LoadTilesUseCase>(
    () => LoadTilesUseCase(sl<FormEngineRepository>()),
  );
  sl.registerLazySingleton<LoadDraftUseCase>(
    () => LoadDraftUseCase(sl<FormEngineRepository>()),
  );
  sl.registerLazySingleton<SaveDraftUseCase>(
    () => SaveDraftUseCase(sl<FormEngineRepository>()),
  );
  sl.registerFactory<FramePerformanceService>(FramePerformanceService.new);
  sl.registerFactory<FormEngineCubit>(
    () => FormEngineCubit(
      loadTilesUseCase: sl<LoadTilesUseCase>(),
      loadDraftUseCase: sl<LoadDraftUseCase>(),
      saveDraftUseCase: sl<SaveDraftUseCase>(),
      framePerformanceService: sl<FramePerformanceService>(),
    ),
  );
  sl.registerFactory<StaticModuleCubit>(
    () => StaticModuleCubit(
      evaluateUseCase: sl<EvaluateLosUseCase>(),
      saveLosDraftUseCase: sl<SaveLosDraftUseCase>(),
      executeLosActionUseCase: sl<ExecuteLosActionUseCase>(),
      submitLosUseCase: sl<SubmitLosUseCase>(),
      loadDraftUseCase: sl<LoadDraftUseCase>(),
      saveDraftUseCase: sl<SaveDraftUseCase>(),
      picklistCacheService: sl<PicklistCacheService>(),
      framePerformanceService: sl<FramePerformanceService>(),
      draftConflictResolver: sl<DraftConflictResolver>(),
      fieldStateMapper: sl<FieldStateMapper>(),
    ),
  );

  sl.registerLazySingleton<LosRemoteDataSource>(
    () => LosRemoteDataSourceImpl(sl<BaseApiService>()),
  );
  sl.registerLazySingleton<LosRepository>(
    () => LosRepositoryImpl(sl<LosRemoteDataSource>()),
  );
  sl.registerLazySingleton<CreateLosApplicationUseCase>(
    () => CreateLosApplicationUseCase(sl<LosRepository>()),
  );
  sl.registerLazySingleton<EvaluateLosUseCase>(
    () => EvaluateLosUseCase(sl<LosRepository>()),
  );
  sl.registerLazySingleton<ExecuteLosActionUseCase>(
    () => ExecuteLosActionUseCase(sl<LosRepository>()),
  );
  sl.registerLazySingleton<SaveLosDraftUseCase>(
    () => SaveLosDraftUseCase(sl<LosRepository>()),
  );
  sl.registerLazySingleton<SubmitLosUseCase>(
    () => SubmitLosUseCase(sl<LosRepository>()),
  );
  sl.registerLazySingleton<ApplicationFlowCubit>(
    () => ApplicationFlowCubit(
      createApplicationUseCase: sl<CreateLosApplicationUseCase>(),
      evaluateUseCase: sl<EvaluateLosUseCase>(),
      executeActionUseCase: sl<ExecuteLosActionUseCase>(),
      saveDraftUseCase: sl<SaveLosDraftUseCase>(),
      submitUseCase: sl<SubmitLosUseCase>(),
    ),
  );
}
