import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> getCategoryById(String id);
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  CategoryRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  String? get currentUserId => auth.currentUser?.uid;

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể lấy danh mục từ Firestore', name: 'CategoryRemoteDataSource');
        return [];
      }

      developer.log('Đang lấy danh mục cho người dùng: $currentUserId', name: 'Firestore');
      final querySnapshot = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .get();

      developer.log('Đã lấy ${querySnapshot.docs.length} danh mục từ Firestore', name: 'Firestore');
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = data['id'] ?? doc.id;
        return CategoryModel.fromJson(data);
      }).toList();
    } catch (e) {
      developer.log('Lỗi khi lấy danh mục từ Firestore: $e', name: 'Firestore', error: e);
      throw Exception('Không thể lấy danh mục từ Firestore: $e');
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể lấy danh mục từ Firestore', name: 'CategoryRemoteDataSource');
        throw Exception('Không có người dùng đăng nhập');
      }

      developer.log('Đang lấy danh mục với ID $id cho người dùng: $currentUserId', name: 'Firestore');
      final docSnapshot = await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc(id)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('Không tìm thấy danh mục với ID $id');
      }

      final data = docSnapshot.data()!;
      data['id'] = data['id'] ?? docSnapshot.id;
      return CategoryModel.fromJson(data);
    } catch (e) {
      developer.log('Lỗi khi lấy danh mục từ Firestore: $e', name: 'Firestore', error: e);
      throw Exception('Không thể lấy danh mục từ Firestore: $e');
    }
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể thêm danh mục vào Firestore', name: 'CategoryRemoteDataSource');
        throw Exception('Không có người dùng đăng nhập');
      }

      developer.log('Đang thêm danh mục ${category.name} cho người dùng: $currentUserId', name: 'Firestore');
      
      final docRef = firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc(category.id);

      await docRef.set(category.toJson());
      developer.log('Đã thêm danh mục ${category.name} với ID ${docRef.id} vào Firestore', name: 'Firestore');
    } catch (e) {
      developer.log('Lỗi khi thêm danh mục vào Firestore: $e', name: 'Firestore', error: e);
      throw Exception('Không thể thêm danh mục vào Firestore: $e');
    }
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể cập nhật danh mục trong Firestore', name: 'CategoryRemoteDataSource');
        throw Exception('Không có người dùng đăng nhập');
      }

      developer.log('Đang cập nhật danh mục ${category.name} cho người dùng: $currentUserId', name: 'Firestore');
      
      final docRef = firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc(category.id);

      // Kiểm tra xem danh mục có tồn tại không
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        developer.log('Danh mục không tồn tại, thử thêm mới', name: 'Firestore');
        await addCategory(category);
        return;
      }

      await docRef.update(category.toJson());
      developer.log('Đã cập nhật danh mục ${category.name} với ID ${category.id} trong Firestore', name: 'Firestore');
    } catch (e) {
      developer.log('Lỗi khi cập nhật danh mục trong Firestore: $e', name: 'Firestore', error: e);
      throw Exception('Không thể cập nhật danh mục trong Firestore: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      if (currentUserId == null) {
        developer.log('Không có người dùng đăng nhập, không thể xóa danh mục khỏi Firestore', name: 'CategoryRemoteDataSource');
        throw Exception('Không có người dùng đăng nhập');
      }

      developer.log('Đang xóa danh mục với ID $id cho người dùng: $currentUserId', name: 'Firestore');
      
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('categories')
          .doc(id)
          .delete();

      developer.log('Đã xóa danh mục với ID $id khỏi Firestore', name: 'Firestore');
    } catch (e) {
      developer.log('Lỗi khi xóa danh mục khỏi Firestore: $e', name: 'Firestore', error: e);
      throw Exception('Không thể xóa danh mục khỏi Firestore: $e');
    }
  }
} 