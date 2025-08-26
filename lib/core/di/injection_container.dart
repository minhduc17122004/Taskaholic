import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Feature: Task - Currently implemented
import '../../features/task/domain/usecases/add_task.dart';
import '../../features/task/domain/usecases/clear_completed_tasks.dart';
import '../../features/task/domain/usecases/delete_task.dart';
import '../../features/task/domain/usecases/get_completed_tasks.dart';
import '../../features/task/domain/usecases/get_task_by_id.dart';
import '../../features/task/domain/usecases/get_tasks.dart';
import '../../features/task/domain/usecases/toggle_task.dart';
import '../../features/task/domain/usecases/update_task.dart';
import '../../features/task/presentation/bloc/task_bloc.dart';

// Core Services - Currently implemented
import '../services/notification_service.dart';

// TODO: Implement these features later
// import '../../features/task/data/datasources/local_datasource.dart';
// import '../../features/task/data/datasources/remote_datasource.dart';
// import '../../features/task/data/repositories/task_repository_impl.dart';

// TODO: Legacy imports for transition - Remove after refactor complete
// import '../../domain/usecases/update_tasks_category.dart';
// import '../../presentation/bloc/task/task_bloc.dart' as legacy;
// import '../../domain/usecases/add_task.dart' as legacy_usecase;
// import '../../domain/usecases/delete_task.dart' as legacy_usecase;
// import '../../domain/usecases/get_tasks.dart' as legacy_usecase;
// import '../../domain/usecases/toggle_task.dart' as legacy_usecase;
// import '../../domain/usecases/update_task.dart' as legacy_usecase;
// import '../../domain/repositories/task_repository.dart' as legacy_repo;
// import '../../data/repositories/task_repository_impl.dart' as legacy_repo_impl;
// import '../../data/datasources/local/task_local_datasource.dart' as legacy_local;
// import '../../data/datasources/remote/task_remote_datasource.dart' as legacy_remote;

// Feature: Auth - Now implemented
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// TODO: Feature: Category - Not implemented yet
// import '../../presentation/pages/category/category_bloc.dart';
// import '../../domain/repositories/category_repository.dart';
// import '../../data/repositories/category_repository_impl.dart';
// import '../../data/datasources/local/category_local_datasource.dart';
// import '../../data/datasources/remote/category_remote_datasource.dart';

// TODO: Home BLoC - Not implemented yet
// import '../../presentation/pages/home/home_bloc.dart';

// TODO: Additional services - Not implemented yet
// import '../services/category_service.dart';
// import '../services/category_notifier.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> init() async {
  // Core dependencies - Essential services
  await _registerCore();
  
  // Task feature - Currently implemented
  _registerTaskFeature();
  
  // Auth feature - Now implemented
  _registerAuthFeature();
  
  // TODO: Uncomment when these features are implemented
  // _registerCategoryFeature();
  // _registerHomeFeature();
}

/// Register core dependencies
Future<void> _registerCore() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Core services registration - Register individually for type safety
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<NotificationService>(() => NotificationServiceImpl());
}

/// Register Task feature dependencies
void _registerTaskFeature() {
  // Task BLoC
  sl.registerFactory(
    () => TaskBloc(
      getTasks: sl(),
      addTask: sl(),
      updateTask: sl(),
      deleteTask: sl(),
      toggleTask: sl(),
      notificationService: sl(),
    ),
  );

  // Task use cases - Register individually for type safety
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => GetCompletedTasks(sl()));
  sl.registerLazySingleton(() => GetTaskById(sl()));
  sl.registerLazySingleton(() => AddTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
  sl.registerLazySingleton(() => ToggleTask(sl()));
  sl.registerLazySingleton(() => ClearCompletedTasks(sl()));

  // TODO: Task repository and data sources
  // sl.registerLazySingleton<TaskRepository>(
  //   () => TaskRepositoryImpl(
  //     localDataSource: sl(),
  //     remoteDataSource: sl(),
  //   ),
  // );
  
  // TODO: Task data sources
  // sl.registerLazySingleton<TaskLocalDataSource>(
  //   () => TaskLocalDataSourceImpl(sharedPreferences: sl()),
  // );
  // sl.registerLazySingleton<TaskRemoteDataSource>(
  //   () => TaskRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  // );
}

/// Register Auth feature dependencies
void _registerAuthFeature() {
  // Auth BLoC
  sl.registerFactory(
    () => AuthBloc(
      signInWithEmailAndPassword: sl(),
      signUpWithEmailAndPassword: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
    ),
  );

  // Auth use cases - Register individually for type safety
  sl.registerLazySingleton(() => SignInWithEmailAndPassword(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailAndPassword(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Auth repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Auth data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );
}

/// TODO: Register Category feature dependencies
// void _registerCategoryFeature() {
//   // Category BLoC
//   sl.registerFactory(
//     () => CategoryBloc(
//       categoryRepository: sl(),
//       categoryService: sl(),
//       updateTasksCategory: sl(),
//       categoryNotifier: sl(),
//     ),
//   );
//
//   // Category repository
//   sl.registerLazySingleton<CategoryRepository>(
//     () => CategoryRepositoryImpl(
//       localDataSource: sl(),
//       remoteDataSource: sl(),
//     ),
//   );
//
//   // Category data sources
//   sl.registerLazySingleton<CategoryLocalDataSource>(
//     () => CategoryLocalDataSourceImpl(sharedPreferences: sl()),
//   );
//   sl.registerLazySingleton<CategoryRemoteDataSource>(
//     () => CategoryRemoteDataSourceImpl(firestore: sl(), auth: sl()),
//   );
// }

/// TODO: Register Home feature dependencies
// void _registerHomeFeature() {
//   sl.registerFactory(() => HomeBloc());
// }

/// Reset all dependencies (call on logout)
void reset() {
  sl.reset();
} 