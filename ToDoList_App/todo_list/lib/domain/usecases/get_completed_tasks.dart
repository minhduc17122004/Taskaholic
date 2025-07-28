import 'package:dartz/dartz.dart' hide Task;
import '../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetCompletedTasks {
  final TaskRepository repository;

  GetCompletedTasks(this.repository);

  Future<Either<Failure, List<Task>>> call() {
    return repository.getCompletedTasks();
  }
} 