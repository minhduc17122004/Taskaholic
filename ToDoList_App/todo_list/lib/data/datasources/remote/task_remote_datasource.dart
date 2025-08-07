import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<List<TaskModel>> getCompletedTasks();
  Future<DocumentReference> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  TaskRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  // Lấy userId hiện tại, nếu không có thì trả về null
  String? get currentUserId => firebaseAuth.currentUser?.uid;

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      // Kiểm tra người dùng đã đăng nhập chưa
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể lấy tasks', name: 'Firestore');
        return [];
      }
      
      developer.log('Đang lấy tasks cho người dùng: $currentUserId', name: 'Firestore');
      
      // Lấy tasks của người dùng hiện tại (chỉ lấy các task chưa hoàn thành)
      final querySnapshot = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .where('isCompleted', isEqualTo: false)
          .get();
          
      developer.log('Đã lấy ${querySnapshot.docs.length} tasks chưa hoàn thành từ Firestore', name: 'Firestore');
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = data['id'] ?? doc.id; // Đảm bảo ID tồn tại
        return TaskModel.fromJson(data);
      }).toList();
    } catch (e) {
      developer.log('Lỗi khi lấy tasks: $e', name: 'Firestore', error: e);
      return [];
    }
  }
  
  @override
  Future<List<TaskModel>> getCompletedTasks() async {
    try {
      // Kiểm tra người dùng đã đăng nhập chưa
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể lấy tasks đã hoàn thành', name: 'Firestore');
        return [];
      }
      
      developer.log('Đang lấy tasks đã hoàn thành cho người dùng: $currentUserId', name: 'Firestore');
      
      // Lấy tasks đã hoàn thành của người dùng hiện tại
      final querySnapshot = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .where('isCompleted', isEqualTo: true)
          .get();
          
      developer.log('Đã lấy ${querySnapshot.docs.length} tasks đã hoàn thành từ Firestore', name: 'Firestore');
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = data['id'] ?? doc.id; // Đảm bảo ID tồn tại
        return TaskModel.fromJson(data);
      }).toList();
    } catch (e) {
      developer.log('Lỗi khi lấy tasks đã hoàn thành: $e', name: 'Firestore', error: e);
      return [];
    }
  }

  @override
  Future<DocumentReference> addTask(TaskModel task) async {
    try {
      // Kiểm tra người dùng đã đăng nhập chưa
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể thêm task', name: 'Firestore');
        throw Exception('Không có người dùng đăng nhập');
      }
      
      developer.log('Đang thêm task: ${task.title} cho người dùng: $currentUserId', name: 'Firestore');
      developer.log('Task data: ${task.toJson()}', name: 'Firestore');
      
      // Thêm task vào collection của người dùng
      final docRef = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .add(task.toJson());
          
      developer.log('Đã thêm task thành công với ID: ${docRef.id}', name: 'Firestore');
      
      // Kiểm tra xem task đã được thêm thành công chưa
      final addedDoc = await docRef.get();
      if (addedDoc.exists) {
        developer.log('Xác nhận task đã được thêm thành công: ${addedDoc.data()}', name: 'Firestore');
      } else {
        developer.log('Không thể xác nhận task đã được thêm', name: 'Firestore');
      }
      
      return docRef;
    } catch (e) {
      developer.log('Lỗi khi thêm task: $e', name: 'Firestore', error: e);
      throw Exception('Không thể thêm task: $e');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      // Kiểm tra người dùng đã đăng nhập chưa
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể cập nhật task', name: 'Firestore');
        return;
      }
      
      developer.log('Đang cập nhật task: ${task.id} cho người dùng: $currentUserId', name: 'Firestore');
      
      // Tìm task theo ID
      final query = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .where('id', isEqualTo: task.id)
          .get();
      
      if (query.docs.isEmpty) {
        developer.log('Không tìm thấy task với ID: ${task.id}, thử thêm mới', name: 'Firestore');
        
        // Nếu không tìm thấy, thêm mới task
        await firestore
            .collection('users')
            .doc(currentUserId)
            .collection('tasks')
            .add(task.toJson());
            
        developer.log('Đã thêm task mới thay vì cập nhật', name: 'Firestore');
        return;
      }
      
      // Cập nhật task
      for (var doc in query.docs) {
        await doc.reference.update(task.toJson());
      }
      
      developer.log('Đã cập nhật task thành công', name: 'Firestore');
    } catch (e) {
      developer.log('Lỗi khi cập nhật task: $e', name: 'Firestore', error: e);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      // Kiểm tra người dùng đã đăng nhập chưa
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể xóa task', name: 'Firestore');
        return;
      }
      
      developer.log('Đang xóa task: $id cho người dùng: $currentUserId', name: 'Firestore');
      
      // Tìm task theo ID
      final query = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .where('id', isEqualTo: id)
          .get();
      
      if (query.docs.isEmpty) {
        developer.log('Không tìm thấy task với ID: $id', name: 'Firestore');
        return;
      }
      
      // Xóa task
      for (var doc in query.docs) {
        await doc.reference.delete();
      }
      
      developer.log('Đã xóa task thành công', name: 'Firestore');
    } catch (e) {
      developer.log('Lỗi khi xóa task: $e', name: 'Firestore', error: e);
    }
  }
}