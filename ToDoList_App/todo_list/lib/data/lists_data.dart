import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/constants/category_constants.dart';
import '../core/services/category_service.dart';
import '../core/di/injection_container.dart' as di;

class ListsData {
  // Get CategoryService from dependency injection
  static CategoryService get _categoryService => di.sl<CategoryService>();
  
  // Legacy static lists for backward compatibility
  static final List<String> lists = [
    CategoryConstants.allTasksCategoryName,
    'Công việc',
    'Mặc định',
  ];
  
  // Legacy list options for backward compatibility
  static final List<String> listOptions = [
    CategoryConstants.allTasksCategoryName,
    'Công việc',
    'Mặc định',
  ];
  
  /// Get all available categories for display (includes system categories like "All Tasks")
  static List<String> getAllDisplayCategories() {
    return _categoryService.getAllDisplayCategories().map((cat) => cat.name).toList();
  }
  
  /// Get selectable categories for task assignment (excludes system categories)
  static List<String> getSelectableCategories() {
    return _categoryService.getSelectableCategoryNames();
  }
  
  /// Legacy method: Get categories for add task screen (excludes system categories)
  static List<String> getAddTaskListOptions() {
    try {
      final selectableCategories = getSelectableCategories();
      
      // Ensure backward compatibility by including legacy categories
      final categories = <String>[];
      categories.addAll(selectableCategories);
      
      // Đảm bảo luôn có các danh mục mặc định
      if (!categories.contains('Công việc')) {
        categories.add('Công việc');
      }
      if (!categories.contains('Mặc định')) {
        categories.add('Mặc định');
      }
      
      // Remove duplicates and system categories
      final uniqueCategories = categories.toSet().toList();
      uniqueCategories.removeWhere((cat) => 
          cat == CategoryConstants.allTasksCategoryName ||
          cat == CategoryConstants.completedCategoryName);
      
      // Đảm bảo luôn có ít nhất một danh mục
      if (uniqueCategories.isEmpty) {
        uniqueCategories.add('Mặc định');
      }
      
      return uniqueCategories;
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách danh mục: $e');
      // Trường hợp lỗi, trả về danh mục mặc định
      return ['Mặc định', 'Công việc'];
    }
  }
  
  /// Get categories for navigation/display (includes "All Tasks" but not "Completed")
  static List<String> getNavigationCategories() {
    final categories = <String>[CategoryConstants.allTasksCategoryName];
    categories.addAll(getSelectableCategories());
    return categories;
  }
  
  /// Check if a category is valid for task assignment
  static bool isValidCategoryForAssignment(String categoryName) {
    return _categoryService.isValidCategoryForAssignment(categoryName);
  }
  
  /// Get category color for display
  static Color getCategoryColor(String categoryName) {
    return _categoryService.getCategoryColor(categoryName);
  }
  
  /// Get category icon for display
  static IconData getCategoryIcon(String categoryName) {
    return _categoryService.getCategoryIcon(categoryName);
  }
  
  /// Add a new custom category
  static void addCustomCategory(String name, {String? color, IconData? icon}) {
    final categoryInfo = CategoryInfo(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      color: color ?? '#607D8B',
      icon: icon ?? Icons.folder,
      isDefault: false,
      isSystem: false,
    );
    
    _categoryService.addCustomCategory(categoryInfo);
    
    // Update legacy lists for backward compatibility
    if (!lists.contains(name)) {
      lists.add(name);
      listOptions.add(name);
    }
  }
  
  /// Remove a custom category
  static void removeCustomCategory(String categoryName) {
    final category = _categoryService.getCategoryByName(categoryName);
    if (category != null && !category.isDefault && !category.isSystem) {
      _categoryService.removeCustomCategory(category.id);
      
      // Update legacy lists
      lists.remove(categoryName);
      listOptions.remove(categoryName);
    }
  }
  
  /// Initialize the category system
  static void initialize() {
    _categoryService.initializeDefaultCategories();
  }
  
  /// Save custom categories to persistent storage
  static Future<void> saveCustomCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customCategories = _categoryService.getSelectableCategories()
          .where((cat) => !cat.isDefault)
          .toList();
      
      final categoriesJson = customCategories.map((cat) => {
        'id': cat.id,
        'name': cat.name,
        'color': cat.color,
        'icon': cat.icon.codePoint,
        'isDefault': cat.isDefault,
        'isSystem': cat.isSystem,
      }).toList();
      
      await prefs.setString('custom_categories', json.encode(categoriesJson));
      debugPrint('Successfully saved ${categoriesJson.length} custom categories');
    } catch (e) {
      debugPrint('Error saving custom categories: $e');
    }
  }
  
  /// Load custom categories from persistent storage
  static Future<void> loadCustomCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesString = prefs.getString('custom_categories');
      
      if (categoriesString != null) {
        final List<dynamic> categoriesJson = json.decode(categoriesString);
        
        for (var categoryData in categoriesJson) {
          final categoryInfo = CategoryInfo(
            id: categoryData['id'],
            name: categoryData['name'],
            color: categoryData['color'],
            icon: IconData(categoryData['icon'], fontFamily: 'MaterialIcons'),
            isDefault: categoryData['isDefault'] ?? false,
            isSystem: categoryData['isSystem'] ?? false,
          );
          
          _categoryService.addCustomCategory(categoryInfo);
          
          // Update legacy lists
          if (!lists.contains(categoryInfo.name)) {
            lists.add(categoryInfo.name);
            listOptions.add(categoryInfo.name);
          }
        }
        debugPrint('Successfully loaded ${categoriesJson.length} custom categories');
      }
    } catch (e) {
      debugPrint('Error loading custom categories: $e');
    }
  }
}
