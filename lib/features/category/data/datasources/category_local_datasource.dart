import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/themes/app_color.dart';
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
  
  /// Xóa toàn bộ danh mục từ local storage (để debug hoặc reset app)
  Future<void> clearLocalCategories();
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
      // Kiểm tra tính hợp lệ của tên danh mục
      final validationError = _validateCategoryName(name);
      if (validationError != null) {
        throw Exception(validationError);
      }
      
      final categories = await getCategories();
      final trimmedName = name.trim();
      
      // Kiểm tra xem danh mục đã tồn tại chưa
      if (categories.any((category) => category.name.toLowerCase() == trimmedName.toLowerCase())) {
        throw Exception('Danh mục đã tồn tại');
      }
      
      // Tạo ID mới
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Tạo danh mục mới
      final newCategory = CategoryModel(
        id: id,
        name: trimmedName,
        createdAt: DateTime.now(),
        taskCount: 0,
        isSystem: false,
        color: AppColors.getCategoryColorByName(trimmedName),
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
      // Kiểm tra tính hợp lệ của tên danh mục
      final validationError = _validateCategoryName(category.name);
      if (validationError != null) {
        throw Exception(validationError);
      }
      
      final categories = await getCategories();
      final trimmedName = category.name.trim();
      
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
      if (categories.any((c) => c.id != category.id && c.name.toLowerCase() == trimmedName.toLowerCase())) {
        throw Exception('Tên danh mục đã tồn tại');
      }
      
      // Cập nhật danh mục với tên đã được trim
      final updatedCategory = category.copyWith(name: trimmedName);
      categories[index] = updatedCategory;
      await saveCategories(categories);
      
      return updatedCategory;
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
  
  @override
  Future<void> clearLocalCategories() async {
    try {
      await sharedPreferences.remove(_categoriesKey);
      developer.log('Đã xóa toàn bộ danh mục từ local storage', name: 'CategoryLocalDataSource');
    } catch (e) {
      developer.log('Lỗi khi xóa toàn bộ danh mục: $e', name: 'CategoryLocalDataSource', error: e);
      rethrow;
    }
  }
  
  // Kiểm tra tính hợp lệ của tên danh mục
  String? _validateCategoryName(String name) {
    // Kiểm tra tên rỗng hoặc chỉ chứa khoảng trắng
    if (name.trim().isEmpty) {
      return 'Tên danh mục không được để trống';
    }
    
    // Kiểm tra độ dài tối thiểu
    if (name.trim().length < 2) {
      return 'Tên danh mục phải có ít nhất 2 ký tự';
    }
    
    // Kiểm tra độ dài tối đa
    if (name.trim().length > 50) {
      return 'Tên danh mục không được quá 50 ký tự';
    }
    
    // Kiểm tra ký tự đặc biệt không được phép
    final RegExp specialCharsPattern = RegExp(r'[<>:"/\\|?*]');
    if (specialCharsPattern.hasMatch(name)) {
      return 'Tên danh mục không được chứa ký tự đặc biệt: < > : " / \\ | ? *';
    }
    
    // Kiểm tra không bắt đầu hoặc kết thúc bằng dấu chấm
    if (name.trim().startsWith('.') || name.trim().endsWith('.')) {
      return 'Tên danh mục không được bắt đầu hoặc kết thúc bằng dấu chấm';
    }
    
    return null; // Hợp lệ
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