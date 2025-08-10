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
  ];
  
  // Legacy list options for backward compatibility
  static final List<String> listOptions = [
    CategoryConstants.allTasksCategoryName,
    'Công việc',
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
      
      // Use LinkedHashSet to maintain order and ensure uniqueness
      final uniqueCategories = <String>{};
      
      // Add selectable categories first (this includes both default and custom)
      uniqueCategories.addAll(selectableCategories);
      
      // Ensure base default category 'Công việc'
      if (!uniqueCategories.contains('Công việc')) {
        uniqueCategories.add('Công việc');
      }
      
      // Remove system categories
      uniqueCategories.removeWhere((cat) => 
          cat == CategoryConstants.allTasksCategoryName ||
          cat == CategoryConstants.completedCategoryName);
      
      // Convert to list and ensure we have at least one category (fallback to 'Công việc')
      final result = uniqueCategories.toList();
      if (result.isEmpty) {
        result.add('Công việc');
      }
      
      return result;
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách danh mục: $e');
      // Trường hợp lỗi, trả về danh mục nền tảng
      return ['Công việc'];
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
      isSystem: false,
    );
    
    _categoryService.addCustomCategory(categoryInfo);
    
    // Update legacy lists for backward compatibility (add to beginning)
    if (!lists.contains(name)) {
      lists.insert(0, name); // Insert at beginning instead of end
      listOptions.insert(0, name); // Insert at beginning instead of end
    }
  }
  
  /// Remove a custom category
  static void removeCustomCategory(String categoryName) {
    final category = _categoryService.getCategoryByName(categoryName);
    if (category != null && !category.isSystem) {
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
      final customCategories = _categoryService.getSelectableCategories().toList();
      
      final categoriesJson = customCategories.map((cat) => {
        'id': cat.id,
        'name': cat.name,
        'color': cat.color,
        'icon': cat.icon.codePoint,
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
            isSystem: categoryData['isSystem'] ?? false,
          );
          
          _categoryService.addCustomCategory(categoryInfo);
          
          // Update legacy lists (add to beginning)
          if (!lists.contains(categoryInfo.name)) {
            lists.insert(0, categoryInfo.name); // Insert at beginning instead of end
            listOptions.insert(0, categoryInfo.name); // Insert at beginning instead of end
          }
        }
        debugPrint('Successfully loaded ${categoriesJson.length} custom categories');
      }
    } catch (e) {
      debugPrint('Error loading custom categories: $e');
    }
  }
  
  /// Remove all custom categories from persistent storage and memory (for auth changes)
  static Future<void> clearCustomCategoriesStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('custom_categories');
      debugPrint('Cleared custom_categories from SharedPreferences');
    } catch (e) {
      debugPrint('Error clearing custom categories storage: $e');
    }
  }

  /// Clear in-memory custom categories and reset legacy lists to defaults
  static void clearInMemoryCustomCategories() {
    _categoryService.clearCustomCategories();

    final defaultNames = CategoryConstants.getSelectableCategories().map((c) => c.name).toSet();
    // Keep only system All Tasks and default names
    lists.removeWhere((name) => name != CategoryConstants.allTasksCategoryName && !defaultNames.contains(name));
    listOptions.removeWhere((name) => name != CategoryConstants.allTasksCategoryName && !defaultNames.contains(name));

    // Ensure defaults exist
    for (final def in defaultNames) {
      if (!lists.contains(def)) lists.add(def);
      if (!listOptions.contains(def)) listOptions.add(def);
    }
  }

  /// Convenience method to reset categories when auth changes
  static Future<void> resetCategoriesForAuthChange() async {
    await clearCustomCategoriesStorage();
    clearInMemoryCustomCategories();
  }
}
