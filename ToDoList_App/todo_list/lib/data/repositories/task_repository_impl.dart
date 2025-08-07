import 'dart:developer' as developer;
import 'package:dartz/dartz.dart' hide Task;
import '../../core/errors/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/task_local_datasource.dart';
import '../datasources/remote/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      developer.log(
        'Đang lấy danh sách công việc từ local',
        name: 'TaskRepository',
      );
      final localTasks = await localDataSource.getTasks();

      try {
        developer.log('Đang đồng bộ với Firestore', name: 'TaskRepository');
        final remoteTasks = await remoteDataSource.getTasks();

        // Merge local and remote tasks, prioritizing remote for existing IDs
        final Map<String, TaskModel> mergedTasks = {};

        // First add all local tasks
        for (var task in localTasks) {
          mergedTasks[task.id] = task;
        }

        // Then override with remote tasks (which have Firebase IDs)
        for (var task in remoteTasks) {
          mergedTasks[task.id] = task;
        }

        final finalTasks = mergedTasks.values.toList();

        // Cập nhật cache local với dữ liệu đã merge
        await localDataSource.cacheTasks(finalTasks);

        developer.log(
          'Đã đồng bộ và merge ${finalTasks.length} công việc từ Firestore',
          name: 'TaskRepository',
        );
        return Right(finalTasks);
      } catch (e) {
        developer.log(
          'Lỗi khi đồng bộ với Firestore: $e, sử dụng dữ liệu local',
          name: 'TaskRepository',
        );
        return Right(localTasks);
      }
    } catch (e) {
      developer.log(
        'Lỗi khi lấy danh sách công việc: $e',
        name: 'TaskRepository',
      );
      return Left(
        ServerFailure(message: 'Không thể lấy danh sách công việc: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getCompletedTasks() async {
    try {
      developer.log(
        'Đang lấy danh sách công việc đã hoàn thành từ local',
        name: 'TaskRepository',
      );
      final localCompletedTasks = await localDataSource.getCompletedTasks();

      try {
        developer.log(
          'Đang đồng bộ công việc đã hoàn thành với Firestore',
          name: 'TaskRepository',
        );
        final remoteCompletedTasks = await remoteDataSource.getCompletedTasks();

        // Cập nhật cache local với dữ liệu từ remote
        await localDataSource.cacheCompletedTasks(remoteCompletedTasks);

        developer.log(
          'Đã đồng bộ và lấy ${remoteCompletedTasks.length} công việc đã hoàn thành từ Firestore',
          name: 'TaskRepository',
        );
        return Right(remoteCompletedTasks);
      } catch (e) {
        developer.log(
          'Lỗi khi đồng bộ công việc đã hoàn thành với Firestore: $e, sử dụng dữ liệu local',
          name: 'TaskRepository',
        );
        return Right(localCompletedTasks);
      }
    } catch (e) {
      developer.log(
        'Lỗi khi lấy danh sách công việc đã hoàn thành: $e',
        name: 'TaskRepository',
      );
      return Left(
        ServerFailure(
          message: 'Không thể lấy danh sách công việc đã hoàn thành: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> addTask(Task task) async {
    try {
      developer.log(
        'Đang thêm công việc: ${task.title}',
        name: 'TaskRepository',
      );
      final taskModel = TaskModel.fromEntity(task);

      // First, add to Firebase to get the proper document ID
      try {
        developer.log(
          'Đang thêm vào Firestore trước...',
          name: 'TaskRepository',
        );
        final docRef = await remoteDataSource.addTask(taskModel);

        // Create updated task model with Firebase document ID
        final updatedTaskModel = TaskModel(
          id: docRef.id, // Use Firebase document ID
          title: taskModel.title,
          date: taskModel.date,
          time: taskModel.time,
          repeat: taskModel.repeat,
          list: taskModel.list,
          originalList: taskModel.originalList,
          isCompleted: taskModel.isCompleted,
        );

        // Update local cache with correct Firebase ID
        final localTasks = await localDataSource.getTasks();
        localTasks.add(updatedTaskModel);
        await localDataSource.cacheTasks(localTasks);

        developer.log(
          'Đã thêm công việc vào Firestore với ID: ${docRef.id}',
          name: 'TaskRepository',
        );
      } catch (e) {
        developer.log(
          'Lỗi khi thêm vào Firestore, fallback to local: $e',
          name: 'TaskRepository',
        );

        // Fallback: add to local with original ID
        final localTasks = await localDataSource.getTasks();
        localTasks.add(taskModel);
        await localDataSource.cacheTasks(localTasks);
      }

      return const Right(unit);
    } catch (e) {
      developer.log('Lỗi khi thêm công việc: $e', name: 'TaskRepository');
      return Left(ServerFailure(message: 'Không thể thêm công việc: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTask(Task task) async {
    try {
      developer.log('Đang cập nhật task: ${task.id}', name: 'TaskRepository');
      final taskModel = TaskModel.fromEntity(task);

      // Cập nhật trên Firestore
      await remoteDataSource.updateTask(taskModel);

      // Cập nhật trong local cache
      final tasks = await localDataSource.getTasks();
      final completedTasks = await localDataSource.getCompletedTasks();

      final taskIndex = tasks.indexWhere((t) => t.id == task.id);
      if (taskIndex != -1) {
        tasks[taskIndex] = taskModel;
        await localDataSource.cacheTasks(tasks);
      } else {
        final completedIndex = completedTasks.indexWhere(
          (t) => t.id == task.id,
        );
        if (completedIndex != -1) {
          completedTasks[completedIndex] = taskModel;
          await localDataSource.cacheCompletedTasks(completedTasks);
        }
      }

      developer.log('Đã cập nhật task thành công', name: 'TaskRepository');
      return const Right(unit);
    } catch (e) {
      developer.log('Lỗi khi cập nhật task: $e', name: 'TaskRepository');
      return Left(ServerFailure(message: 'Không thể cập nhật task: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTask(String id) async {
    try {
      developer.log('Đang xóa task: $id', name: 'TaskRepository');

      // Xóa trên Firestore
      await remoteDataSource.deleteTask(id);

      // Xóa khỏi local cache
      final tasks = await localDataSource.getTasks();
      final completedTasks = await localDataSource.getCompletedTasks();

      tasks.removeWhere((task) => task.id == id);
      completedTasks.removeWhere((task) => task.id == id);

      await localDataSource.cacheTasks(tasks);
      await localDataSource.cacheCompletedTasks(completedTasks);

      developer.log('Đã xóa task thành công', name: 'TaskRepository');
      return const Right(unit);
    } catch (e) {
      developer.log('Lỗi khi xóa task: $e', name: 'TaskRepository');
      return Left(ServerFailure(message: 'Không thể xóa task: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleTask(String taskId) async {
    try {
      developer.log(
        'Đang chuyển đổi trạng thái task: $taskId',
        name: 'TaskRepository',
      );

      // Tìm task trong danh sách tasks hoặc completedTasks
      Task? task;
      final tasks = await localDataSource.getTasks();
      final completedTasks = await localDataSource.getCompletedTasks();

      task = tasks.firstWhere(
        (t) => t.id == taskId,
        orElse:
            () => completedTasks.firstWhere(
              (t) => t.id == taskId,
              orElse:
                  () => throw Exception('Không tìm thấy task với ID: $taskId'),
            ),
      );

      final wasCompleted = task.isCompleted;

      // Create updated task with proper category handling
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        // When completing: preserve original category in originalList if not already set
        // When uncompleting: restore from originalList or keep current list
        list:
            !task.isCompleted
                ? task
                    .list // Completing: keep current category in list
                : (task.originalList.isNotEmpty ? task.originalList : task.list), // Uncompleting: restore original category
        originalList:
            !task.isCompleted
                ? (task.originalList.isNotEmpty ? task.originalList : task.list) // Completing: preserve original if not set
                : task.originalList, // Uncompleting: keep existing originalList
      );

      if (updatedTask.isCompleted) {
        // Task đang được hoàn thành - chuyển từ tasks sang completedTasks
        developer.log(
          'Đánh dấu task hoàn thành: ${task.title} (category: ${updatedTask.originalList})',
          name: 'TaskRepository',
        );
        tasks.removeWhere((t) => t.id == taskId);
        completedTasks.add(TaskModel.fromEntity(updatedTask));

        await localDataSource.cacheTasks(tasks);
        await localDataSource.cacheCompletedTasks(completedTasks);
      } else {
        // Task đang được bỏ hoàn thành - chuyển từ completedTasks sang tasks
        developer.log(
          'Đánh dấu task chưa hoàn thành: ${task.title} (restored to category: ${updatedTask.list})',
          name: 'TaskRepository',
        );
        completedTasks.removeWhere((t) => t.id == taskId);
        tasks.add(TaskModel.fromEntity(updatedTask));

        await localDataSource.cacheTasks(tasks);
        await localDataSource.cacheCompletedTasks(completedTasks);
      }

      // Cập nhật trên Firestore
      try {
        await remoteDataSource.updateTask(TaskModel.fromEntity(updatedTask));
        developer.log(
          'Đã đồng bộ trạng thái task lên Firestore',
          name: 'TaskRepository',
        );
      } catch (e) {
        developer.log(
          'Lỗi đồng bộ Firestore (task vẫn được cập nhật local): $e',
          name: 'TaskRepository',
        );
        // Không throw error vì local đã được cập nhật thành công
      }

      developer.log(
        'Đã chuyển đổi trạng thái task thành công: ${wasCompleted ? 'completed -> pending' : 'pending -> completed'}',
        name: 'TaskRepository',
      );
      return const Right(unit);
    } catch (e) {
      developer.log(
        'Lỗi khi chuyển đổi trạng thái task: $e',
        name: 'TaskRepository',
      );
      return Left(
        ServerFailure(message: 'Không thể chuyển đổi trạng thái task: $e'),
      );
    }
  }
}
