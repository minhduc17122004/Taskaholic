import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local_datasource.dart';
import '../datasources/remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  final TaskRemoteDataSource remoteDataSource;
  
  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });
  
  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() async {
    try {
      // Thử lấy từ remote trước
      try {
        final remoteTasks = await remoteDataSource.getTasks();
        // Lưu vào local để sử dụng offline
        await localDataSource.saveTasks(remoteTasks);
        return Right(remoteTasks);
      } catch (e) {
        developer.log('Lỗi khi lấy tasks từ remote, sẽ thử lấy từ local: $e', name: 'TaskRepository');
      }
      
      // Nếu không lấy được từ remote, lấy từ local
      final localTasks = await localDataSource.getTasks();
      return Right(localTasks);
    } on Exception catch (e) {
      developer.log('Lỗi khi lấy tasks: $e', name: 'TaskRepository', error: e);
      return Left(ServerFailure(message: 'Không thể lấy danh sách công việc: $e'));
    }
  }
  
  @override
  Future<Either<Failure, List<TaskEntity>>> getCompletedTasks() async {
    try {
      // Thử lấy từ remote trước
      try {
        final remoteTasks = await remoteDataSource.getCompletedTasks();
        // Lưu vào local để sử dụng offline
        await localDataSource.saveCompletedTasks(remoteTasks);
        return Right(remoteTasks);
      } catch (e) {
        developer.log('Lỗi khi lấy completed tasks từ remote, sẽ thử lấy từ local: $e', name: 'TaskRepository');
      }
      
      // Nếu không lấy được từ remote, lấy từ local
      final localTasks = await localDataSource.getCompletedTasks();
      return Right(localTasks);
    } on Exception catch (e) {
      developer.log('Lỗi khi lấy completed tasks: $e', name: 'TaskRepository', error: e);
      return Left(ServerFailure(message: 'Không thể lấy danh sách công việc đã hoàn thành: $e'));
    }
  }
  
  @override
  Future<Either<Failure, TaskEntity>> getTaskById(String id) async {
    try {
      // Lấy tất cả tasks
      final tasksResult = await getTasks();
      final completedTasksResult = await getCompletedTasks();
      
      List<TaskEntity> allTasks = [];
      
      tasksResult.fold(
        (failure) => throw Exception(failure.message),
        (tasks) => allTasks.addAll(tasks),
      );
      
      completedTasksResult.fold(
        (failure) => throw Exception(failure.message),
        (completedTasks) => allTasks.addAll(completedTasks),
      );
      
      // Tìm task theo id
      final task = allTasks.firstWhere(
        (task) => task.id == id,
        orElse: () => throw Exception('Không tìm thấy task với id: $id'),
      );
      
      return Right(task);
    } on Exception catch (e) {
      developer.log('Lỗi khi lấy task theo id: $e', name: 'TaskRepository', error: e);
      return Left(ServerFailure(message: 'Không thể lấy công việc: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> addTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      
      // Thêm vào remote
      try {
        await remoteDataSource.addTask(taskModel);
      } catch (e) {
        developer.log('Lỗi khi thêm task vào remote: $e', name: 'TaskRepository');
      }
      
      // Thêm vào local
      final localTasks = await localDataSource.getTasks();
      localTasks.add(taskModel);
      await localDataSource.saveTasks(localTasks);
      
      return const Right(null);
    } on Exception catch (e) {
      developer.log('Lỗi khi thêm task: $e', name: 'TaskRepository', error: e);
      return Left(ServerFailure(message: 'Không thể thêm công việc: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> updateTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      
      // Cập nhật trên remote
      try {
        await remoteDataSource.updateTask(taskModel);
      } catch (e) {
        developer.log('Lỗi khi cập nhật task trên remote: $e', name: 'TaskRepository');
      }
      
      // Cập nhật trên local
      final localTasks = await localDataSource.getTasks();
      final index = localTasks.indexWhere((t) => t.id == task.id);
      
      if (index != -1) {
        localTasks[index] = taskModel;
        await localDataSource.saveTasks(localTasks);
      } else {
        // Kiểm tra trong completed tasks
        final completedTasks = await localDataSource.getCompletedTasks();
        final completedIndex = completedTasks.indexWhere((t) => t.id == task.id);
        
        if (completedIndex != -1) {
          completedTasks[completedIndex] = taskModel;
          await localDataSource.saveCompletedTasks(completedTasks);
        }
      }
      
      return const Right(null);
    } on Exception catch (e) {
      developer.log('Lỗi khi cập nhật task: $e', name: 'TaskRepository', error: e);
      return Left(ServerFailure(message: 'Không thể cập nhật công việc: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      // Xóa trên remote
      try {
        await remoteDataSource.deleteTask(id);
      } catch (e) {
        developer.log('Lỗi khi xóa task trên remote: $e', name: 'TaskRepository');
      }
      
      // Xóa trên local
      final localTasks = await localDataSource.getTasks();
      final updatedTasks = localTasks.where((task) => task.id != id).toList();
      await localDataSource.saveTasks(updatedTasks);
      
      // Xóa khỏi completed tasks nếu có
      final completedTasks = await localDataSource.getCompletedTasks();
      final updatedCompletedTasks = completedTasks.where((task) => task.id != id).toList();
      await localDataSource.saveCompletedTasks(updatedCompletedTasks);
      
      return const Right(null);
    } on Exception catch (e) {
      developer.log('Lỗi khi xóa task: $e', name: 'TaskRepository', error: e);
      return Left(ServerFailure(message: 'Không thể xóa công việc: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> toggleTask(String id) async {
    try {
      // Lấy task hiện tại
      final taskResult = await getTaskById(id);
      
      return taskResult.fold(
        (failure) => Left(failure),
        (task) async {
          final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
          
          // Toggle trên remote
          try {
            await remoteDataSource.toggleTask(id);
          } catch (e) {
            developer.log('Lỗi khi toggle task trên remote: $e', name: 'TaskRepository');
          }
          
          // Toggle trên local
          if (task.isCompleted) {
            // Task đang được đánh dấu là chưa hoàn thành
            final completedTasks = await localDataSource.getCompletedTasks();
            final updatedCompletedTasks = completedTasks.where((t) => t.id != id).toList();
            await localDataSource.saveCompletedTasks(updatedCompletedTasks);
            
            final tasks = await localDataSource.getTasks();
            tasks.add(TaskModel.fromEntity(updatedTask));
            await localDataSource.saveTasks(tasks);
          } else {
            // Task đang được đánh dấu là hoàn thành
            final tasks = await localDataSource.getTasks();
            final updatedTasks = tasks.where((t) => t.id != id).toList();
            await localDataSource.saveTasks(updatedTasks);
            
            final completedTasks = await localDataSource.getCompletedTasks();
            completedTasks.add(TaskModel.fromEntity(updatedTask));
            await localDataSource.saveCompletedTasks(completedTasks);
          }
          
          return const Right(null);
        },
      );
    } on Exception catch (e) {
      developer.log('Lỗi khi toggle task: $e', name: 'TaskRepository', error: e);
      return Left(ServerFailure(message: 'Không thể thay đổi trạng thái công việc: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> clearCompletedTasks() async {
    try {
      // Lấy danh sách tasks đã hoàn thành
      final completedTasksResult = await getCompletedTasks();
      
      return completedTasksResult.fold(
        (failure) => Left(failure),
        (completedTasks) async {
          // Xóa từng task
          for (var task in completedTasks) {
            try {
              await remoteDataSource.deleteTask(task.id);
            } catch (e) {
              developer.log('Lỗi khi xóa completed task trên remote: $e', name: 'TaskRepository');
            }
          }
          
          // Xóa tất cả trên local
          await localDataSource.saveCompletedTasks([]);
          
          return const Right(null);
        },
      );
    } on Exception catch (e) {
      developer.log('Lỗi khi xóa completed tasks: $e', name: 'TaskRepository', error: e);
      return Left(ServerFailure(message: 'Không thể xóa các công việc đã hoàn thành: $e'));
    }
  }
} 