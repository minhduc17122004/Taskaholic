import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/task_model.dart';
import '../../../core/constants/category_constants.dart';

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

  String? get currentUserId => firebaseAuth.currentUser?.uid;

  bool _isReservedSystemName(String name) {
    return name == CategoryConstants.completedCategoryName ||
        name == CategoryConstants.allTasksCategoryName;
  }

  bool _isValidTime(String s) {
    final regex = RegExp(r'^([01]?\d|2[0-3]):[0-5]\d$');
    return s == '0:0' || regex.hasMatch(s);
  }

  bool _isAllowedRepeat(String s) {
    const allowed = [
      'Không lặp lại',
      'Hàng ngày',
      'Hàng ngày (Thứ 2-Thứ 6)',
      'Hàng tuần',
      'Hàng tháng',
      'Hàng năm',
    ];
    return allowed.contains(s);
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể lấy tasks', name: 'TaskRemoteDataSource');
        return [];
      }

      developer.log('Đang lấy tasks cho người dùng: $currentUserId', name: 'TaskRemoteDataSource');

      final querySnapshot = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .where('isCompleted', isEqualTo: false)
          .orderBy('date', descending: false)
          .get();

      developer.log('Đã lấy ${querySnapshot.docs.length} tasks chưa hoàn thành từ Firestore', name: 'TaskRemoteDataSource');

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = data['id'] ?? doc.id;
        return TaskModel.fromJson(data);
      }).toList();
    } catch (e, s) {
      developer.log('Lỗi khi lấy tasks', name: 'TaskRemoteDataSource', error: e, stackTrace: s);
      rethrow;
    }
  }
  
  @override
  Future<List<TaskModel>> getCompletedTasks() async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể lấy tasks đã hoàn thành', name: 'TaskRemoteDataSource');
        return [];
      }

      developer.log('Đang lấy tasks đã hoàn thành cho người dùng: $currentUserId', name: 'TaskRemoteDataSource');

      final querySnapshot = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .where('isCompleted', isEqualTo: true)
          .orderBy('date', descending: true)
          .get();

      developer.log('Đã lấy ${querySnapshot.docs.length} tasks đã hoàn thành từ Firestore', name: 'TaskRemoteDataSource');

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = data['id'] ?? doc.id;
        return TaskModel.fromJson(data);
      }).toList();
    } catch (e, s) {
      developer.log('Lỗi khi lấy tasks đã hoàn thành', name: 'TaskRemoteDataSource', error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<DocumentReference> addTask(TaskModel task) async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể thêm task', name: 'TaskRemoteDataSource');
        throw Exception('Không có người dùng đăng nhập');
      }

      // Log incoming task data
      final payloadBefore = task.toJson();
      developer.log('Incoming Task payload', name: 'TaskRemoteDataSource', error: payloadBefore);

      // Validations with detailed logs
      final timeStr = payloadBefore['time'] as String;
      final timeOk = _isValidTime(timeStr);
      developer.log('Validate time format: input="$timeStr" -> $timeOk', name: 'TaskRemoteDataSource');
      if (!timeOk) {
        developer.log('Validation failed: invalid time format', name: 'TaskRemoteDataSource');
        throw Exception('Định dạng thời gian không hợp lệ');
      }

      final repeat = payloadBefore['repeat'] as String;
      final repeatOk = _isAllowedRepeat(repeat);
      developer.log('Validate repeat: input="$repeat" -> $repeatOk', name: 'TaskRemoteDataSource');
      if (!repeatOk) {
        developer.log('Validation failed: invalid repeat value', name: 'TaskRemoteDataSource');
        throw Exception('Giá trị repeat không hợp lệ');
      }

      final listName = payloadBefore['list'] as String;
      final isReserved = _isReservedSystemName(listName);
      developer.log('Validate list category: input="$listName" reserved=$isReserved', name: 'TaskRemoteDataSource');
      if (isReserved) {
        developer.log('Validation failed: list is a reserved system category', name: 'TaskRemoteDataSource');
        throw Exception('Không thể gán task vào danh mục hệ thống');
      }

      // Final payload before Firestore
      developer.log('Final payload before Firestore .add(): $payloadBefore', name: 'TaskRemoteDataSource');

      final docRef = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .add(payloadBefore);

      developer.log('Firestore .add() success. New docId=${docRef.id}', name: 'TaskRemoteDataSource');

      return docRef;
    } catch (e, s) {
      developer.log('Lỗi khi thêm task (caught)', name: 'TaskRemoteDataSource', error: e, stackTrace: s);
      throw Exception('Không thể thêm task: $e');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể cập nhật task', name: 'TaskRemoteDataSource');
        return;
      }

      // Log incoming update payload
      final payloadBefore = task.toJson();
      developer.log('Incoming Task update payload', name: 'TaskRemoteDataSource', error: payloadBefore);

      // Validations with detailed logs
      final timeStr = payloadBefore['time'] as String;
      final timeOk = _isValidTime(timeStr);
      developer.log('Validate time format (update): input="$timeStr" -> $timeOk', name: 'TaskRemoteDataSource');
      if (!timeOk) {
        developer.log('Validation failed (update): invalid time format', name: 'TaskRemoteDataSource');
        throw Exception('Định dạng thời gian không hợp lệ');
      }

      final repeat = payloadBefore['repeat'] as String;
      final repeatOk = _isAllowedRepeat(repeat);
      developer.log('Validate repeat (update): input="$repeat" -> $repeatOk', name: 'TaskRemoteDataSource');
      if (!repeatOk) {
        developer.log('Validation failed (update): invalid repeat value', name: 'TaskRemoteDataSource');
        throw Exception('Giá trị repeat không hợp lệ');
      }

      final listName = payloadBefore['list'] as String;
      final isReserved = _isReservedSystemName(listName);
      developer.log('Validate list category (update): input="$listName" reserved=$isReserved', name: 'TaskRemoteDataSource');
      if (isReserved) {
        developer.log('Validation failed (update): list is a reserved system category', name: 'TaskRemoteDataSource');
        throw Exception('Không thể gán task vào danh mục hệ thống');
      }

      developer.log('Finding task by id=${task.id} for update', name: 'TaskRemoteDataSource');

      final querySnap = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .where('id', isEqualTo: task.id)
          .limit(1)
          .get();

      if (querySnap.docs.isEmpty) {
        developer.log('Không tìm thấy task với ID: ${task.id}, thử thêm mới', name: 'TaskRemoteDataSource');
        await firestore
            .collection('users')
            .doc(currentUserId)
            .collection('tasks')
            .add(payloadBefore);
        developer.log('Đã thêm task mới thay vì cập nhật', name: 'TaskRemoteDataSource');
        return;
      }

      developer.log('Updating Firestore docId=${querySnap.docs.first.id} with payload=$payloadBefore', name: 'TaskRemoteDataSource');
      await querySnap.docs.first.reference.update(payloadBefore);
      developer.log('Đã cập nhật task thành công', name: 'TaskRemoteDataSource');
    } catch (e, s) {
      developer.log('Lỗi khi cập nhật task (caught)', name: 'TaskRemoteDataSource', error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể xóa task', name: 'TaskRemoteDataSource');
        return;
      }

      developer.log('Đang xóa task: $id cho người dùng: $currentUserId', name: 'TaskRemoteDataSource');

      final querySnap = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tasks')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (querySnap.docs.isEmpty) {
        developer.log('Không tìm thấy task với ID: $id', name: 'TaskRemoteDataSource');
        return;
      }

      developer.log('Deleting Firestore docId=${querySnap.docs.first.id}', name: 'TaskRemoteDataSource');
      await querySnap.docs.first.reference.delete();
      developer.log('Đã xóa task thành công', name: 'TaskRemoteDataSource');
    } catch (e, s) {
      developer.log('Lỗi khi xóa task (caught)', name: 'TaskRemoteDataSource', error: e, stackTrace: s);
    }
  }
}