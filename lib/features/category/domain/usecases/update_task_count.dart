import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/category_repository.dart';

class UpdateTaskCount implements UseCase<void, UpdateTaskCountParams> {
  final CategoryRepository repository;

  UpdateTaskCount(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateTaskCountParams params) {
    return repository.updateTaskCount(params.categoryId, params.taskCount);
  }
}

class UpdateTaskCountParams extends Equatable {
  final String categoryId;
  final int taskCount;

  const UpdateTaskCountParams({
    required this.categoryId,
    required this.taskCount,
  });

  @override
  List<Object> get props => [categoryId, taskCount];
}
