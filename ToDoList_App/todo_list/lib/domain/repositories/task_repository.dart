import 'package:dartz/dartz.dart' hide Task;
import '../entities/task.dart';
import '../../core/errors/failures.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getTasks();
  Future<Either<Failure, List<Task>>> getCompletedTasks();
  Future<Either<Failure, Unit>> addTask(Task task);
  Future<Either<Failure, Unit>> updateTask(Task task);
  Future<Either<Failure, Unit>> deleteTask(String id);
  Future<Either<Failure, Unit>> toggleTask(String taskId);
} 