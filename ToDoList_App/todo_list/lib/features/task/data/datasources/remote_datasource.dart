import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/task_entity.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  /// Lấy danh sách tasks từ Firestore
  Future<List<TaskModel>> getTasks();
  
  /// Lấy danh sách tasks đã hoàn thành từ Firestore
  Future<List<TaskModel>> getCompletedTasks();
  
  /// Thêm task mới vào Firestore
  Future<void> addTask(TaskModel task);
  
  /// Cập nhật task trong Firestore
  Future<void> updateTask(TaskModel task);
  
  /// Xóa task khỏi Firestore
  Future<void> deleteTask(String id);
  
  /// Đánh dấu task là đã hoàn thành hoặc chưa hoàn thành
  Future<void> toggleTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  
  TaskRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });
  
  String? get currentUserId => firebaseAuth.currentUser?.uid;
  
  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể lấy tasks từ Firestore', name: 'TaskRemoteDataSource');
        return [];
      }
      
      final snapshot = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .where('isCompleted', isEqualTo: false)
          .get();
      
      return snapshot.docs
          .map((doc) => TaskModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      developer.log('Lỗi khi lấy tasks từ Firestore: $e', name: 'TaskRemoteDataSource', error: e);
      return [];
    }
  }
  
  @override
  Future<List<TaskModel>> getCompletedTasks() async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể lấy completed tasks từ Firestore', name: 'TaskRemoteDataSource');
        return [];
      }
      
      final snapshot = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .where('isCompleted', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => TaskModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      developer.log('Lỗi khi lấy completed tasks từ Firestore: $e', name: 'TaskRemoteDataSource', error: e);
      return [];
    }
  }
  
  @override
  Future<void> addTask(TaskModel task) async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể thêm task vào Firestore', name: 'TaskRemoteDataSource');
        return;
      }
      
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .doc(task.id)
          .set(task.toJson());
    } catch (e) {
      developer.log('Lỗi khi thêm task vào Firestore: $e', name: 'TaskRemoteDataSource', error: e);
      rethrow;
    }
  }
  
  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể cập nhật task trong Firestore', name: 'TaskRemoteDataSource');
        return;
      }
      
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .doc(task.id)
          .update(task.toJson());
    } catch (e) {
      developer.log('Lỗi khi cập nhật task trong Firestore: $e', name: 'TaskRemoteDataSource', error: e);
      rethrow;
    }
  }
  
  @override
  Future<void> deleteTask(String id) async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể xóa task khỏi Firestore', name: 'TaskRemoteDataSource');
        return;
      }
      
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .doc(id)
          .delete();
    } catch (e) {
      developer.log('Lỗi khi xóa task khỏi Firestore: $e', name: 'TaskRemoteDataSource', error: e);
      rethrow;
    }
  }
  
  @override
  Future<void> toggleTask(String id) async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể toggle task trong Firestore', name: 'TaskRemoteDataSource');
        return;
      }
      
      // Lấy task hiện tại
      final doc = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .doc(id)
          .get();
      
      if (!doc.exists) {
        throw Exception('Task không tồn tại');
      }
      
      final task = TaskModel.fromJson({...doc.data()!, 'id': doc.id});
      final updatedTask = TaskModel.fromEntity(task.copyWith(isCompleted: !task.isCompleted));
      
      // Cập nhật task
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .doc(id)
          .update(updatedTask.toJson());
    } catch (e) {
      developer.log('Lỗi khi toggle task trong Firestore: $e', name: 'TaskRemoteDataSource', error: e);
      rethrow;
    }
  }
} 