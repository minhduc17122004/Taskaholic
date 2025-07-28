import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  /// Lấy danh sách tất cả các task
  Future<Either<Failure, List<TaskEntity>>> getTasks();
  
  /// Lấy danh sách task đã hoàn thành
  Future<Either<Failure, List<TaskEntity>>> getCompletedTasks();
  
  /// Lấy task theo ID
  Future<Either<Failure, TaskEntity>> getTaskById(String id);
  
  /// Thêm task mới
  Future<Either<Failure, void>> addTask(TaskEntity task);
  
  /// Cập nhật task
  Future<Either<Failure, void>> updateTask(TaskEntity task);
  
  /// Xóa task
  Future<Either<Failure, void>> deleteTask(String id);
  
  /// Đánh dấu task là đã hoàn thành hoặc chưa hoàn thành
  Future<Either<Failure, void>> toggleTask(String id);
  
  /// Xóa tất cả task đã hoàn thành
  Future<Either<Failure, void>> clearCompletedTasks();
} 