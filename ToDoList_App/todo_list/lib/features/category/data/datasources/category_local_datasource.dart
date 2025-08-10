import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  /// Lấy danh sách danh mục từ local storage
  Future<List<CategoryModel>> getCategories();
  
  /// Lưu danh sách danh mục vào local storage
  Future<void> saveCategories(List<CategoryModel> categories);
  
  /// Thêm danh mục mới vào local storage
  Future<CategoryModel> addCategory(String name);
  
  /// Cập nhật danh mục trong local storage
  Future<CategoryModel> updateCategory(CategoryModel category);
  
  /// Xóa danh mục khỏi local storage
  Future<void> deleteCategory(String id);
  
  /// Lấy danh mục theo ID từ local storage
  Future<CategoryModel?> getCategoryById(String id);
  
  /// Cập nhật số lượng công việc trong danh mục
  Future<void> updateTaskCount(String categoryId, int taskCount);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final SharedPreferences sharedPreferences;
  final String _categoriesKey = 'categories';
  
  CategoryLocalDataSourceImpl({required this.sharedPreferences});
  
  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final jsonString = sharedPreferences.getString(_categoriesKey);
      if (jsonString == null) {
        // Khởi tạo các danh mục mặc định nếu chưa có
        final defaultCategories = _getDefaultCategories();
        await saveCategories(defaultCategories);
        return defaultCategories;
      }
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Lỗi khi lấy danh mục từ SharedPreferences: $e', name: 'CategoryLocalDataSource', error: e);
      // Trả về danh mục mặc định nếu có lỗi
      return _getDefaultCategories();
    }
  }
  
  @override
  Future<void> saveCategories(List<CategoryModel> categories) async {
    try {
      final jsonList = categories.map((category) => category.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString(_categoriesKey, jsonString);
    } catch (e) {
      developer.log('Lỗi khi lưu danh mục vào SharedPreferences: $e', name: 'CategoryLocalDataSource', error: e);
      rethrow;
    }
  }
  
  @override
  Future<CategoryModel> addCategory(String name) async {
    try {
      final categories = await getCategories();
      
      // Kiểm tra xem danh mục đã tồn tại chưa
      if (categories.any((category) => category.name.toLowerCase() == name.toLowerCase())) {
        throw Exception('Danh mục đã tồn tại');
      }
      
      // Tạo ID mới
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Tạo danh mục mới
      final newCategory = CategoryModel(
        id: id,
        name: name,
        taskCount: 0,
        isSystem: false,
      );
      
      // Thêm vào danh sách và lưu
      categories.add(newCategory);
      await saveCategories(categories);
      
      return newCategory;
    } catch (e) {
      developer.log('Lỗi khi thêm danh mục: $e', name: 'CategoryLocalDataSource', error: e);
      rethrow;
    }
  }
  
  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final categories = await getCategories();
      
      // Tìm vị trí của danh mục cần cập nhật
      final index = categories.indexWhere((c) => c.id == category.id);
      if (index == -1) {
        throw Exception('Không tìm thấy danh mục');
      }
      
      // Kiểm tra xem đây có phải là danh mục hệ thống không
      if (categories[index].isSystem) {
        throw Exception('Không thể cập nhật danh mục hệ thống');
      }
      
      // Kiểm tra xem tên mới đã tồn tại chưa (trừ chính nó)
      if (categories.any((c) => c.id != category.id && c.name.toLowerCase() == category.name.toLowerCase())) {
        throw Exception('Tên danh mục đã tồn tại');
      }
      
      // Cập nhật danh mục
      categories[index] = category;
      await saveCategories(categories);
      
      return category;
    } catch (e) {
      developer.log('Lỗi khi cập nhật danh mục: $e', name: 'CategoryLocalDataSource', error: e);
      rethrow;
    }
  }
  
  @override
  Future<void> deleteCategory(String id) async {
    try {
      final categories = await getCategories();
      
      // Tìm danh mục cần xóa
      final CategoryModel category = categories.firstWhere(
        (c) => c.id == id,
        orElse: () => throw Exception('Không tìm thấy danh mục'),
      );
      
      // Kiểm tra xem đây có phải là danh mục hệ thống không
      if (category.isSystem) {
        throw Exception('Không thể xóa danh mục hệ thống');
      }
      
      // Xóa danh mục
      categories.removeWhere((c) => c.id == id);
      await saveCategories(categories);
    } catch (e) {
      developer.log('Lỗi khi xóa danh mục: $e', name: 'CategoryLocalDataSource', error: e);
      rethrow;
    }
  }
  
  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final categories = await getCategories();
      final matches = categories.where((category) => category.id == id);
      return matches.isNotEmpty ? matches.first : null;
    } catch (e) {
      developer.log('Lỗi khi lấy danh mục theo ID: $e', name: 'CategoryLocalDataSource', error: e);
      return null;
    }
  }
  
  @override
  Future<void> updateTaskCount(String categoryId, int taskCount) async {
    try {
      final categories = await getCategories();
      
      // Tìm vị trí của danh mục cần cập nhật
      final index = categories.indexWhere((c) => c.id == categoryId);
      if (index == -1) {
        throw Exception('Không tìm thấy danh mục');
      }
      
      // Cập nhật số lượng công việc
      final updatedCategory = CategoryModel.fromEntity(
        categories[index].copyWith(taskCount: taskCount)
      );
      categories[index] = updatedCategory;
      
      await saveCategories(categories);
    } catch (e) {
      developer.log('Lỗi khi cập nhật số lượng công việc: $e', name: 'CategoryLocalDataSource', error: e);
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