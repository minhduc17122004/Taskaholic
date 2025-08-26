import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/themes/app_color.dart';
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
  
  // Cache để tối ưu việc kiểm tra trùng lặp
  List<CategoryModel>? _cachedCategories;
  DateTime? _lastCacheTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);
  
  CategoryRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });
  
  String? get currentUserId => firebaseAuth.currentUser?.uid;
  
  /// Kiểm tra cache có còn hợp lệ không
  bool get _isCacheValid {
    if (_cachedCategories == null || _lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheTimeout;
  }
  
  /// Cập nhật cache
  void _updateCache(List<CategoryModel> categories) {
    _cachedCategories = List.from(categories);
    _lastCacheTime = DateTime.now();
  }
  
  /// Xóa cache
  void _clearCache() {
    _cachedCategories = null;
    _lastCacheTime = null;
  }
  
  /// Lấy danh sách categories từ cache hoặc server
  Future<List<CategoryModel>> _getCategoriesWithCache() async {
    if (_isCacheValid) {
      return _cachedCategories!;
    }
    
    final categories = await _fetchCategoriesFromServer();
    _updateCache(categories);
    return categories;
  }
  
  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể lấy danh mục từ Firestore', name: 'CategoryRemoteDataSource');
        throw const UnauthorizedFailure(message: 'Không có người dùng đăng nhập');
      }
      
      return await _getCategoriesWithCache();
    } catch (e) {
      if (e is Failure) rethrow;
      developer.log('Lỗi khi lấy danh mục từ Firestore: $e', name: 'CategoryRemoteDataSource', error: e);
      throw ServerFailure(message: 'Lỗi khi lấy danh mục: $e');
    }
  }
  
  /// Lấy danh mục từ server (không cache)
  Future<List<CategoryModel>> _fetchCategoriesFromServer() async {
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
            .set(category.toCreateJson());
      }
      return defaultCategories;
    }
    
    return snapshot.docs
        .map((doc) => CategoryModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }
  
  @override
  Future<CategoryModel> addCategory(String name) async {
    try {
      if (currentUserId == null) {
        throw const UnauthorizedFailure(message: 'Không có người dùng đăng nhập');
      }
      
      // Kiểm tra xem danh mục đã tồn tại chưa (sử dụng cache để tối ưu)
      final existingCategories = await _getCategoriesWithCache();
      if (existingCategories.any((category) => category.name.toLowerCase() == name.toLowerCase())) {
        throw const DuplicateFailure(message: 'Danh mục đã tồn tại');
      }
      
      // Tạo ID mới
      final docRef = firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc();
      
      // Tạo danh mục mới với server timestamps
      final newCategory = CategoryModel(
        id: docRef.id,
        name: name,
        createdAt: DateTime.now(), // Sẽ được ghi đè bởi server timestamp
        taskCount: 0,
        isSystem: false,
        color: AppColors.getCategoryColorByName(name),
      );
      
      // Lưu vào Firestore với server timestamps
      await docRef.set(newCategory.toCreateJson());
      
      // Xóa cache để reload từ server lần sau
      _clearCache();
      
      return newCategory;
    } catch (e) {
      if (e is Failure) rethrow;
      developer.log('Lỗi khi thêm danh mục vào Firestore: $e', name: 'CategoryRemoteDataSource', error: e);
      throw ServerFailure(message: 'Lỗi khi thêm danh mục: $e');
    }
  }
  
  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      if (currentUserId == null) {
        throw const UnauthorizedFailure(message: 'Không có người dùng đăng nhập');
      }
      
      // Kiểm tra xem danh mục có tồn tại không
      final doc = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc(category.id)
          .get();
      
      if (!doc.exists) {
        throw const NotFoundFailure(message: 'Không tìm thấy danh mục');
      }
      
      // Kiểm tra xem đây có phải là danh mục hệ thống không
      final existingCategory = CategoryModel.fromJson({...doc.data()!, 'id': doc.id});
      if (existingCategory.isSystem) {
        throw const SystemResourceFailure(message: 'Không thể cập nhật danh mục hệ thống');
      }
      
      // Kiểm tra xem tên mới đã tồn tại chưa (sử dụng cache để tối ưu)
      final existingCategories = await _getCategoriesWithCache();
      if (existingCategories.any((c) => c.id != category.id && c.name.toLowerCase() == category.name.toLowerCase())) {
        throw const DuplicateFailure(message: 'Tên danh mục đã tồn tại');
      }
      
      // Cập nhật danh mục với server timestamp
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc(category.id)
          .update(category.toUpdateJson());
      
      // Xóa cache để reload từ server lần sau
      _clearCache();
      
      return category;
    } catch (e) {
      if (e is Failure) rethrow;
      developer.log('Lỗi khi cập nhật danh mục trong Firestore: $e', name: 'CategoryRemoteDataSource', error: e);
      throw ServerFailure(message: 'Lỗi khi cập nhật danh mục: $e');
    }
  }
  
  @override
  Future<void> deleteCategory(String id) async {
    try {
      if (currentUserId == null) {
        throw const UnauthorizedFailure(message: 'Không có người dùng đăng nhập');
      }
      
      // Kiểm tra xem danh mục có tồn tại không
      final doc = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc(id)
          .get();
      
      if (!doc.exists) {
        throw const NotFoundFailure(message: 'Không tìm thấy danh mục');
      }
      
      // Kiểm tra xem đây có phải là danh mục hệ thống không
      final category = CategoryModel.fromJson({...doc.data()!, 'id': doc.id});
      if (category.isSystem) {
        throw const SystemResourceFailure(message: 'Không thể xóa danh mục hệ thống');
      }
      
      // Xóa danh mục
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc(id)
          .delete();
      
      // Xóa cache để reload từ server lần sau
      _clearCache();
    } catch (e) {
      if (e is Failure) rethrow;
      developer.log('Lỗi khi xóa danh mục khỏi Firestore: $e', name: 'CategoryRemoteDataSource', error: e);
      throw ServerFailure(message: 'Lỗi khi xóa danh mục: $e');
    }
  }
  
  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      if (currentUserId == null) {
        throw const UnauthorizedFailure(message: 'Không có người dùng đăng nhập');
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
      if (e is Failure) rethrow;
      developer.log('Lỗi khi lấy danh mục theo ID từ Firestore: $e', name: 'CategoryRemoteDataSource', error: e);
      throw ServerFailure(message: 'Lỗi khi lấy danh mục: $e');
    }
  }
  
  @override
  Future<void> updateTaskCount(String categoryId, int taskCount) async {
    try {
      if (currentUserId == null) {
        throw const UnauthorizedFailure(message: 'Không có người dùng đăng nhập');
      }
      
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc(categoryId)
          .update({
            'taskCount': taskCount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      
      // Xóa cache để reload từ server lần sau
      _clearCache();
    } catch (e) {
      if (e is Failure) rethrow;
      developer.log('Lỗi khi cập nhật số lượng công việc trong Firestore: $e', name: 'CategoryRemoteDataSource', error: e);
      throw ServerFailure(message: 'Lỗi khi cập nhật số lượng công việc: $e');
    }
  }
  
  // Danh sách danh mục mặc định
  List<CategoryModel> _getDefaultCategories() {
    final now = DateTime.now();
    return [
      CategoryModel(
        id: 'work',
        name: 'Công việc',
        createdAt: now,
        updatedAt: now,
        taskCount: 0,
        isSystem: false,
        color: AppColors.categoryWork,
      ),
      CategoryModel(
        id: 'personal',
        name: 'Cá nhân',
        createdAt: now,
        updatedAt: now,
        taskCount: 0,
        isSystem: false,
        color: AppColors.categoryPersonal,
      ),
      CategoryModel(
        id: 'study',
        name: 'Học tập',
        createdAt: now,
        updatedAt: now,
        taskCount: 0,
        isSystem: false,
        color: AppColors.categoryStudy,
      ),
      CategoryModel(
        id: 'health',
        name: 'Sức khỏe',
        createdAt: now,
        updatedAt: now,
        taskCount: 0,
        isSystem: false,
        color: AppColors.categoryHealth,
      ),
      CategoryModel(
        id: 'shopping',
        name: 'Mua sắm',
        createdAt: now,
        updatedAt: now,
        taskCount: 0,
        isSystem: false,
        color: AppColors.categoryShopping,
      ),
    ];
  }
} 