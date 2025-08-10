import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';
import 'get_tasks.dart';
import 'update_task.dart';

class UpdateTasksCategoryParams {
  final String oldCategoryName;
  final String newCategoryName;

  UpdateTasksCategoryParams({
    required this.oldCategoryName,
    required this.newCategoryName,
  });
}

class UpdateTasksCategory implements UseCase<void, UpdateTasksCategoryParams> {
  final TaskRepository repository;
  final GetTasks getTasks;
  final UpdateTask updateTask;

  UpdateTasksCategory({
    required this.repository,
    required this.getTasks,
    required this.updateTask,
  });

  @override
  Future<Either<Failure, void>> call(UpdateTasksCategoryParams params) async {
    try {
      // Get all tasks
      final tasksResult = await getTasks.call();
      
      return await tasksResult.fold(
        (failure) => Left(failure),
        (tasksData) async {
          // Find all tasks that belong to the old category
          final tasksToUpdate = [
            ...tasksData.tasks.where((task) => task.list == params.oldCategoryName),
            ...tasksData.completedTasks.where((task) => task.list == params.oldCategoryName || task.originalList == params.oldCategoryName),
          ];

          // Update each task with the new category name
          for (final task in tasksToUpdate) {
            final updatedTask = task.copyWith(
              list: task.list == params.oldCategoryName ? params.newCategoryName : task.list,
              originalList: task.originalList == params.oldCategoryName ? params.newCategoryName : task.originalList,
            );
            
            final updateResult = await updateTask(updatedTask);
            if (updateResult.isLeft()) {
              // If any update fails, return the failure
              return updateResult;
            }
          }
          
          return const Right(unit);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Không thể cập nhật danh mục cho các công việc: $e'));
    }
  }
} 