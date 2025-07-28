import 'package:dartz/dartz.dart' hide Task;
import '../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class TasksResult {
  final List<Task> tasks;
  final List<Task> completedTasks;

  TasksResult({required this.tasks, required this.completedTasks});
}

class GetTasks {
  final TaskRepository repository;

  GetTasks(this.repository);

  Future<Either<Failure, TasksResult>> call() async {
    final tasksResult = await repository.getTasks();
    final completedTasksResult = await repository.getCompletedTasks();

    return tasksResult.fold(
      (failure) => Left(failure),
      (tasks) => completedTasksResult.fold(
        (failure) => Left(failure),
        (completedTasks) => Right(TasksResult(
          tasks: tasks,
          completedTasks: completedTasks,
        )),
      ),
    );
  }
} 