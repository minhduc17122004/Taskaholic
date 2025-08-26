import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks();
  
  Future<Either<Failure, List<TaskEntity>>> getCompletedTasks();
  
  Future<Either<Failure, TaskEntity>> getTaskById(String id);
  
  Future<Either<Failure, void>> addTask(TaskEntity task);
  
  Future<Either<Failure, void>> updateTask(TaskEntity task);
  
  Future<Either<Failure, void>> deleteTask(String id);
  
  Future<Either<Failure, void>> toggleTask(String id);
  
  Future<Either<Failure, void>> clearCompletedTasks();

} 