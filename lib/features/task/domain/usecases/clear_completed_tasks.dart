import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

class ClearCompletedTasks implements UseCase<void, NoParams> {
  final TaskRepository repository;

  ClearCompletedTasks(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.clearCompletedTasks();
  }
} 