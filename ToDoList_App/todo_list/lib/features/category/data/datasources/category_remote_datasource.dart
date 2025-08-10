import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  /// Lấy danh sách danh mục từ Firestore
  Future<List<CategoryModel>> getCategories();
  
  /// Thêm danh mục mới vào Firestore
  Future<CategoryModel> addCategory(String name);
  
  /// Cập nhật danh mục trong Firestore
  Future<CategoryModel> updateCategory(CategoryModel category);
  
  /// Xóa danh mục khỏi Firestore
  Future<void> deleteCategory(String id);
  
  /// Lấy danh mục theo ID từ Firestore
  Future<CategoryModel?> getCategoryById(String id);
  
  /// Cập nhật số lượng công việc trong danh mục
  Future<void> updateTaskCount(String categoryId, int taskCount);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  
  CategoryRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });
  
  String? get currentUserId => firebaseAuth.currentUser?.uid;
  
  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể lấy danh mục từ Firestore', name: 'CategoryRemoteDataSource');
        return [];
      }
      
      final snapshot = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .get();
      
      if (snapshot.docs.isEmpty) {
        // Khởi tạo các danh mục mặc định nếu chưa có
        final defaultCategories = _getDefaultCategories();
        for (var category in defaultCategories) {
          await firestore
              .collection('users')
              .doc(currentUserId)
              .collection('categories')
              .doc(category.id)
              .set(category.toJson());
        }
        return defaultCategories;
      }
      
      return snapshot.docs
          .map((doc) => CategoryModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      developer.log('Lỗi khi lấy danh mục từ Firestore: $e', name: 'CategoryRemoteDataSource', error: e);
      return [];
    }
  }
  
  @override
  Future<CategoryModel> addCategory(String name) async {
    try {
      if (currentUserId == null) {
        throw Exception('Không có người dùng đăng nhập');
      }
      
      // Kiểm tra xem danh mục đã tồn tại chưa
      final existingCategories = await getCategories();
      if (existingCategories.any((category) => category.name.toLowerCase() == name.toLowerCase())) {
        throw Exception('Danh mục đã tồn tại');
      }
      
      // Tạo ID mới
      final docRef = firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc();
      
      // Tạo danh mục mới
      final newCategory = CategoryModel(
        id: docRef.id,
        name: name,
        taskCount: 0,
        isSystem: false,
      );
      
      // Lưu vào Firestore
      await docRef.set(newCategory.toJson());
      
      return newCategory;
    } catch (e) {
      developer.log('Lỗi khi thêm danh mục vào Firestore: $e', name: 'CategoryRemoteDataSource', error: e);
      rethrow;
    }
  }
  
  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      if (currentUserId == null) {
        throw Exception('Không có người dùng đăng nhập');
      }
      
      // Kiểm tra xem danh mục có tồn tại không
      final doc = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc(category.id)
          .get();
      
      if (!doc.exists) {
        throw Exception('Không tìm thấy danh mục');
      }
      
      // Kiểm tra xem đây có phải là danh mục hệ thống không
      final existingCategory = CategoryModel.fromJson({...doc.data()!, 'id': doc.id});
      if (existingCategory.isSystem) {
        throw Exception('Không thể cập nhật danh mục hệ thống');
      }
      
      // Kiểm tra xem tên mới đã tồn tại chưa
      final existingCategories = await getCategories();
      if (existingCategories.any((c) => c.id != category.id && c.name.toLowerCase() == category.name.toLowerCase())) {
        throw Exception('Tên danh mục đã tồn tại');
      }
      
      // Cập nhật danh mục
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc(category.id)
          .update(category.toJson());
      
      return category;
    } catch (e) {
      developer.log('Lỗi khi cập nhật danh mục trong Firestore: $e', name: 'CategoryRemoteDataSource', error: e);
      rethrow;
    }
  }
  
  @override
  Future<void> deleteCategory(String id) async {
    try {
      if (currentUserId == null) {
        throw Exception('Không có người dùng đăng nhập');
      }
      
      // Kiểm tra xem danh mục có tồn tại không
      final doc = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc(id)
          .get();
      
      if (!doc.exists) {
        throw Exception('Không tìm thấy danh mục');
      }
      
      // Kiểm tra xem đây có phải là danh mục hệ thống không
      final category = CategoryModel.fromJson({...doc.data()!, 'id': doc.id});
      if (category.isSystem) {
        throw Exception('Không thể xóa danh mục hệ thống');
      }
      
      // Xóa danh mục
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc(id)
          .delete();
    } catch (e) {
      developer.log('Lỗi khi xóa danh mục khỏi Firestore: $e', name: 'CategoryRemoteDataSource', error: e);
      rethrow;
    }
  }
  
  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      if (currentUserId == null) {
        throw Exception('Không có người dùng đăng nhập');
      }
      
      final doc = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc(id)
          .get();
      
      if (!doc.exists) {
        return null;
      }
      
      return CategoryModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      developer.log('Lỗi khi lấy danh mục theo ID từ Firestore: $e', name: 'CategoryRemoteDataSource', error: e);
      rethrow;
    }
  }
  
  @override
  Future<void> updateTaskCount(String categoryId, int taskCount) async {
    try {
      if (currentUserId == null) {
        throw Exception('Không có người dùng đăng nhập');
      }
      
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc(categoryId)
          .update({'taskCount': taskCount});
    } catch (e) {
      developer.log('Lỗi khi cập nhật số lượng công việc trong Firestore: $e', name: 'CategoryRemoteDataSource', error: e);
      rethrow;
    }
  }
  
  // Danh sách danh mục mặc định
  List<CategoryModel> _getDefaultCategories() {
    return [
      const CategoryModel(
        id: 'all',
        name: 'Danh sách tất cả',
        taskCount: 0,
        isSystem: true,
      ),
    ];
  }
} 