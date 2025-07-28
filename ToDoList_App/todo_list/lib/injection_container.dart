import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/local/task_local_datasource.dart';
import 'data/datasources/remote/task_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/task_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/task_repository.dart';
import 'domain/usecases/add_task.dart';
import 'domain/usecases/delete_task.dart';
import 'domain/usecases/get_completed_tasks.dart';
import 'domain/usecases/get_current_user.dart';
import 'domain/usecases/get_tasks.dart';
import 'domain/usecases/sign_in_with_email_and_password.dart';
import 'domain/usecases/sign_out.dart';
import 'domain/usecases/sign_up_with_email_and_password.dart';
import 'domain/usecases/toggle_task.dart';
import 'domain/usecases/update_task.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/task/task_bloc.dart';
import 'presentation/pages/category/category_bloc.dart';
import 'presentation/pages/home/home_bloc.dart';
import 'presentation/pages/add_task/add_task_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(
    () => TaskBloc(
      getTasks: sl(),
      addTask: sl(),
      updateTask: sl(),
      deleteTask: sl(),
      toggleTask: sl(),
    ),
  );
  
  sl.registerFactory(
    () => AuthBloc(
      signInWithEmailAndPassword: sl(),
      signUpWithEmailAndPassword: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
    ),
  );
  
  sl.registerFactory(
    () => CategoryBloc(),
  );
  
  sl.registerFactory(
    () => HomeBloc(),
  );
  
  sl.registerFactory(
    () => AddTaskBloc(
      addTask: sl(),
      updateTask: sl(),
      deleteTask: sl(),
    ),
  );

  // Use cases - Task
  sl.registerLazySingleton(() => GetTasks(sl()));
  sl.registerLazySingleton(() => GetCompletedTasks(sl()));
  sl.registerLazySingleton(() => AddTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
  sl.registerLazySingleton(() => ToggleTask(sl()));
  
  // Use cases - Auth
  sl.registerLazySingleton(() => SignInWithEmailAndPassword(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailAndPassword(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );
  
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
    ),
  );
  
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
} 