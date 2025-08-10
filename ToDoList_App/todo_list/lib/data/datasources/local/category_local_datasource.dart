import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> getCategoryById(String id);
  Future<void> cacheCategories(List<CategoryModel> categories);
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<void> clearCategories();
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const CACHED_CATEGORIES = 'CACHED_CATEGORIES';

  CategoryLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<CategoryModel>> getCategories() async {
    developer.log('Lấy danh sách danh mục từ SharedPreferences', name: 'CategoryLocalDataSource');
    final jsonString = sharedPreferences.getString(CACHED_CATEGORIES);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((jsonItem) => CategoryModel.fromJson(jsonItem)).toList();
    }
    return [];
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    developer.log('Lấy danh mục với ID $id từ SharedPreferences', name: 'CategoryLocalDataSource');
    final categories = await getCategories();
    final category = categories.firstWhere(
      (category) => category.id == id,
      orElse: () => throw Exception('Không tìm thấy danh mục với ID $id'),
    );
    return category;
  }

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    developer.log('Lưu ${categories.length} danh mục vào SharedPreferences', name: 'CategoryLocalDataSource');
    final List<Map<String, dynamic>> jsonList = categories.map((category) => category.toJson()).toList();
    await sharedPreferences.setString(CACHED_CATEGORIES, json.encode(jsonList));
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    developer.log('Thêm danh mục ${category.name} vào SharedPreferences', name: 'CategoryLocalDataSource');
    final categories = await getCategories();
    categories.add(category);
    await cacheCategories(categories);
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    developer.log('Cập nhật danh mục ${category.name} trong SharedPreferences', name: 'CategoryLocalDataSource');
    final categories = await getCategories();
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      await cacheCategories(categories);
    } else {
      throw Exception('Không tìm thấy danh mục với ID ${category.id} để cập nhật');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    developer.log('Xóa danh mục với ID $id khỏi SharedPreferences', name: 'CategoryLocalDataSource');
    final categories = await getCategories();
    categories.removeWhere((category) => category.id == id);
    await cacheCategories(categories);
  }

  @override
  Future<void> clearCategories() async {
    developer.log('Xóa toàn bộ danh mục khỏi SharedPreferences', name: 'CategoryLocalDataSource');
    await sharedPreferences.remove(CACHED_CATEGORIES);
  }
} 