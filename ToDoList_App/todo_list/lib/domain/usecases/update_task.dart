import 'package:dartz/dartz.dart' hide Task;
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class UpdateTask implements UseCase<void, Task> {
  final TaskRepository repository;

  UpdateTask(this.repository);

  @override
  Future<Either<Failure, void>> call(Task task) {
    return repository.updateTask(task);
  }
} 