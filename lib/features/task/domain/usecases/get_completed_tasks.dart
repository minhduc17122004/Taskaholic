import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetCompletedTasks implements UseCase<List<TaskEntity>, NoParams> {
  final TaskRepository repository;

  GetCompletedTasks(this.repository);

  @override
  Future<Either<Failure, List<TaskEntity>>> call(NoParams params) {
    return repository.getCompletedTasks();
  }
} 