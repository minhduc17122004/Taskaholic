import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

class ToggleTask implements UseCase<void, String> {
  final TaskRepository repository;

  ToggleTask(this.repository);

  @override
  Future<Either<Failure, void>> call(String taskId) {
    return repository.toggleTask(taskId);
  }
} 