import 'package:get_it/get_it.dart';

import '../../features/application/data/datasources/application_remote_datasource.dart';
import '../../features/application/data/repositories/application_repository_impl.dart';
import '../../features/application/domain/repositories/application_repository.dart';
import '../../features/application/domain/usecases/action_usecase.dart';
import '../../features/application/domain/usecases/create_application_usecase.dart';
import '../../features/application/domain/usecases/evaluate_usecase.dart';
import '../../features/application/domain/usecases/save_draft_usecase.dart';
import '../../features/application/domain/usecases/submit_usecase.dart';
import '../../features/application/presentation/cubit/application_cubit.dart';
import '../network/api_client.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  sl.registerLazySingleton<ApplicationRemoteDataSource>(
    () => ApplicationRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<ApplicationRepository>(
    () => ApplicationRepositoryImpl(sl<ApplicationRemoteDataSource>()),
  );

  sl.registerLazySingleton<CreateApplicationUseCase>(
    () => CreateApplicationUseCase(sl<ApplicationRepository>()),
  );
  sl.registerLazySingleton<EvaluateUseCase>(
    () => EvaluateUseCase(sl<ApplicationRepository>()),
  );
  sl.registerLazySingleton<ActionUseCase>(
    () => ActionUseCase(sl<ApplicationRepository>()),
  );
  sl.registerLazySingleton<SaveDraftUseCase>(
    () => SaveDraftUseCase(sl<ApplicationRepository>()),
  );
  sl.registerLazySingleton<SubmitUseCase>(
    () => SubmitUseCase(sl<ApplicationRepository>()),
  );

  sl.registerFactory<ApplicationCubit>(
    () => ApplicationCubit(
      createApplicationUseCase: sl<CreateApplicationUseCase>(),
      evaluateUseCase: sl<EvaluateUseCase>(),
      actionUseCase: sl<ActionUseCase>(),
      saveDraftUseCase: sl<SaveDraftUseCase>(),
      submitUseCase: sl<SubmitUseCase>(),
    ),
  );
}
