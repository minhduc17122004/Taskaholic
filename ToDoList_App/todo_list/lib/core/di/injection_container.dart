import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Feature: Task
import '../../features/task/data/datasources/local_datasource.dart';
import '../../features/task/data/datasources/remote_datasource.dart';
import '../../features/task/data/repositories/task_repository_impl.dart';
import '../../features/task/domain/repositories/task_repository.dart';
import '../../features/task/domain/usecases/add_task.dart';
import '../../features/task/domain/usecases/clear_completed_tasks.dart';
import '../../features/task/domain/usecases/delete_task.dart';
import '../../features/task/domain/usecases/get_completed_tasks.dart';
import '../../features/task/domain/usecases/get_task_by_id.dart';
import '../../features/task/domain/usecases/get_tasks.dart';
import '../../features/task/domain/usecases/toggle_task.dart';
import '../../features/task/domain/usecases/update_task.dart';
import '../../features/task/presentation/bloc/task_bloc.dart';

// Legacy usecases for category operations
import '../../domain/usecases/update_tasks_category.dart';

// Legacy Task (for transition)
import '../../presentation/bloc/task/task_bloc.dart' as legacy;
import '../../domain/usecases/add_task.dart' as legacy_usecase;
import '../../domain/usecases/delete_task.dart' as legacy_usecase;
import '../../domain/usecases/get_tasks.dart' as legacy_usecase;
import '../../domain/usecases/toggle_task.dart' as legacy_usecase;
import '../../domain/usecases/update_task.dart' as legacy_usecase;
import '../../domain/repositories/task_repository.dart' as legacy_repo;
import '../../data/repositories/task_repository_impl.dart' as legacy_repo_impl;
import '../../data/datasources/local/task_local_datasource.dart' as legacy_local;
import '../../data/datasources/remote/task_remote_datasource.dart' as legacy_remote;

// Feature: Auth
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_email_and_password.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email_and_password.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';

// Feature: Category
import '../../presentation/pages/category/category_bloc.dart';
import '../../domain/repositories/category_repository.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/datasources/local/category_local_datasource.dart';
import '../../data/datasources/remote/category_remote_datasource.dart';

// Home
import '../../presentation/pages/home/home_bloc.dart';

// Core
import '../services/notification_service.dart';
import '../services/category_service.dart';
import '../services/category_notifier.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => CategoryService());
  sl.registerLazySingleton(() => CategoryNotifier());

  // Feature: Task
  // Bloc
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
  
  // Legacy Data sources
  sl.registerLazySingleton<legacy_local.TaskLocalDataSource>(
    () => legacy_local.TaskLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );
  
  sl.registerLazySingleton<legacy_remote.TaskRemoteDataSource>(
    () => legacy_remote.TaskRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );
  
  // Legacy Task Repository
  sl.registerLazySingleton<legacy_repo.TaskRepository>(
    () => legacy_repo_impl.TaskRepositoryImpl(
      localDataSource: sl<legacy_local.TaskLocalDataSource>(),
      remoteDataSource: sl<legacy_remote.TaskRemoteDataSource>(),
    ),
  );
  
  // Legacy Task Bloc (for transition)
  sl.registerFactory(
    () => legacy.TaskBloc(
      getTasks: sl<legacy_usecase.GetTasks>(),
      addTask: sl<legacy_usecase.AddTask>(),
      updateTask: sl<legacy_usecase.UpdateTask>(),
      deleteTask: sl<legacy_usecase.DeleteTask>(),
      toggleTask: sl<legacy_usecase.ToggleTask>(),
    ),
  );
  
  // Legacy Use cases (for transition)
  sl.registerLazySingleton(() => legacy_usecase.GetTasks(sl<legacy_repo.TaskRepository>()));
  sl.registerLazySingleton(() => legacy_usecase.AddTask(sl<legacy_repo.TaskRepository>()));
  sl.registerLazySingleton(() => legacy_usecase.UpdateTask(sl<legacy_repo.TaskRepository>()));
  sl.registerLazySingleton(() => legacy_usecase.DeleteTask(sl<legacy_repo.TaskRepository>()));
  sl.registerLazySingleton(() => legacy_usecase.ToggleTask(sl<legacy_repo.TaskRepository>()));
  
  // Category-related use cases
  sl.registerLazySingleton(() => UpdateTasksCategory(
    repository: sl<legacy_repo.TaskRepository>(),
    getTasks: sl<legacy_usecase.GetTasks>(),
    updateTask: sl<legacy_usecase.UpdateTask>(),
  ));

  // Use cases
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => GetCompletedTasks(sl()));
  sl.registerLazySingleton(() => GetTaskById(sl()));
  sl.registerLazySingleton(() => AddTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
  sl.registerLazySingleton(() => ToggleTask(sl()));
  sl.registerLazySingleton(() => ClearCompletedTasks(sl()));

  // Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );
  
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );

  // Feature: Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      signInWithEmailAndPassword: sl(),
      signUpWithEmailAndPassword: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInWithEmailAndPassword(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUpWithEmailAndPassword(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOut(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUser(sl<AuthRepository>()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
    ),
  );
  
  // Home
  sl.registerFactory(() => HomeBloc());

  // Feature: Category
  // Bloc
  sl.registerFactory(
    () => CategoryBloc(
      categoryRepository: sl(),
      categoryService: sl(),
      updateTasksCategory: sl(),
      categoryNotifier: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );
  
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(
      firestore: sl(),
      auth: sl(),
    ),
  );
} 