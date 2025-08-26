import 'package:get_it/get_it.dart';
import 'package:taskaholic/core/services/notification_service.dart';
import 'package:taskaholic/features/task/presentation/bloc/task_bloc.dart';
import 'package:taskaholic/features/task/domain/usecases/add_task.dart';
import 'package:taskaholic/features/task/domain/usecases/delete_task.dart';
import 'package:taskaholic/features/task/domain/usecases/get_tasks.dart';
import 'package:taskaholic/features/task/domain/usecases/toggle_task.dart';
import 'package:taskaholic/features/task/domain/usecases/update_task.dart';

final getIt = GetIt.instance;

/// Register notification service dependencies
void initNotificationDependencies() {
  // Register NotificationService
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationServiceImpl(),
  );
}

/// Example function showing how to create TaskBloc with injected NotificationService
TaskBloc createTaskBloc() {
  return TaskBloc(
    getTasks: getIt<GetTasks>(),
    addTask: getIt<AddTask>(),
    updateTask: getIt<UpdateTask>(),
    deleteTask: getIt<DeleteTask>(),
    toggleTask: getIt<ToggleTask>(),
    notificationService: getIt<NotificationService>(), // 
  );
}

/// Alternative: Direct injection without GetIt
TaskBloc createTaskBlocDirect({
  required GetTasks getTasks,
  required AddTask addTask,
  required UpdateTask updateTask,
  required DeleteTask deleteTask,
  required ToggleTask toggleTask,
  NotificationService? notificationService,
}) {
  return TaskBloc(
    getTasks: getTasks,
    addTask: addTask,
    updateTask: updateTask,
    deleteTask: deleteTask,
    toggleTask: toggleTask,
    notificationService: notificationService ?? NotificationServiceImpl(),
  );
}

