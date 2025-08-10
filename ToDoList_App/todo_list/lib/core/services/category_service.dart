import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../constants/category_constants.dart';
import '../../domain/entities/task.dart';

/// Service for managing task categories and filtering
class CategoryService {
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  // User-defined custom categories (loaded from storage/database)
  final List<CategoryInfo> _customCategories = [];

  /// Get all available categories for display (including system categories)
  List<CategoryInfo> getAllDisplayCategories() {
    return [
      ...CategoryConstants.systemCategories,
      ...CategoryConstants.defaultCategories,
      ..._customCategories,
    ];
  }

  /// Get selectable categories for task assignment (excludes system categories)
  List<CategoryInfo> getSelectableCategories() {
    final categories = <CategoryInfo>[];
    
    // Add default categories first
    categories.addAll(CategoryConstants.getSelectableCategories());
    
    // Add custom categories, but avoid duplicates by name
    for (final customCat in _customCategories.where((cat) => !cat.isSystem)) {
      if (!categories.any((cat) => cat.name == customCat.name)) {
        categories.add(customCat);
      }
    }
    
    return categories;
  }

  /// Get category names for dropdowns (excludes system categories)
  List<String> getSelectableCategoryNames() {
    return getSelectableCategories().map((cat) => cat.name).toList();
  }

  /// Add a custom category (insert at beginning)
  void addCustomCategory(CategoryInfo category) {
    // Check for duplicates by both ID and name to prevent duplicates
    if (!_customCategories.any((cat) => cat.id == category.id || cat.name == category.name)) {
      _customCategories.insert(0, category); // Insert at beginning instead of end
      developer.log('Added custom category: ${category.name}', name: 'CategoryService');
    } else {
      developer.log('Category already exists, skipping add: ${category.name}', name: 'CategoryService');
    }
  }

  /// Remove a custom category
  void removeCustomCategory(String categoryId) {
    _customCategories.removeWhere((cat) => cat.id == categoryId);
    developer.log('Removed custom category: $categoryId', name: 'CategoryService');
  }

  /// Get category by ID from all categories
  CategoryInfo? getCategoryById(String categoryId) {
    // First check constants
    var category = CategoryConstants.getCategoryById(categoryId);
    if (category != null) return category;

    // Then check custom categories with safe lookup
    try {
      final matches = _customCategories.where((cat) => cat.id == categoryId);
      return matches.isNotEmpty ? matches.first : null;
    } catch (e) {
      developer.log('Error finding category by ID "$categoryId": $e', name: 'CategoryService');
      return null;
    }
  }

  /// Get category by name from all categories
  CategoryInfo? getCategoryByName(String categoryName) {
    if (categoryName.isEmpty) return null;
    
    // First check constants
    var category = CategoryConstants.getCategoryByName(categoryName);
    if (category != null) return category;

    // Then check custom categories with safe lookup
    try {
      final matches = _customCategories.where((cat) => cat.name == categoryName);
      return matches.isNotEmpty ? matches.first : null;
    } catch (e) {
      developer.log('Error finding category "$categoryName": $e', name: 'CategoryService');
      return null;
    }
  }

  /// Filter tasks by category, handling completed tasks specially
  List<Task> getTasksByCategory(List<Task> tasks, String categoryName, {bool includeCompleted = false}) {
    // Handle "All Tasks" special case
    if (categoryName == CategoryConstants.allTasksCategoryName) {
      return includeCompleted ? tasks : tasks.where((task) => !task.isCompleted).toList();
    }

    // Handle "Completed" special case
    if (categoryName == CategoryConstants.completedCategoryName) {
      return tasks.where((task) => task.isCompleted).toList();
    }

    // Filter by regular category
    var filteredTasks = tasks.where((task) => task.list == categoryName).toList();
    
    if (!includeCompleted) {
      filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
    }

    return filteredTasks;
  }

  /// Group tasks by their actual categories (for display)
  Map<String, List<Task>> groupTasksByCategory(List<Task> tasks, {bool includeCompleted = false}) {
    final Map<String, List<Task>> grouped = {};

    for (var task in tasks) {
      if (!includeCompleted && task.isCompleted) {
        continue; // Skip completed tasks if not requested
      }

      final categoryName = task.isCompleted 
          ? CategoryConstants.completedCategoryName 
          : task.list;

      if (!grouped.containsKey(categoryName)) {
        grouped[categoryName] = [];
      }
      grouped[categoryName]!.add(task);
    }

    return grouped;
  }

  /// Group completed tasks by their original categories
  Map<String, List<Task>> groupCompletedTasksByOriginalCategory(List<Task> completedTasks) {
    final Map<String, List<Task>> grouped = {};

    for (var task in completedTasks.where((t) => t.isCompleted)) {
      final originalCategory = task.originalList.isNotEmpty ? task.originalList : task.list;

      if (!grouped.containsKey(originalCategory)) {
        grouped[originalCategory] = [];
      }
      grouped[originalCategory]!.add(task);
    }

    return grouped;
  }

  /// Get time-based category for a task (for display purposes)
  String getTimeCategoryForTask(Task task) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final endOfWeek = today.add(Duration(days: 7 - now.weekday));
    final taskDay = DateTime(task.date.year, task.date.month, task.date.day);

    if (taskDay.isBefore(today)) {
      return 'Quá hạn';
    } else if (taskDay.isAtSameMomentAs(today)) {
      return 'Hôm nay';
    } else if (taskDay.isAtSameMomentAs(tomorrow)) {
      return 'Ngày mai';
    } else if (taskDay.isBefore(endOfWeek) || taskDay.isAtSameMomentAs(endOfWeek)) {
      return 'Tuần này';
    } else {
      return 'Sắp tới';
    }
  }

  /// Group tasks by time-based categories for list view
  Map<String, List<Task>> groupTasksByTimeCategory(List<Task> tasks, String listFilter) {
    List<Task> filteredTasks;
    
    if (listFilter == CategoryConstants.allTasksCategoryName) {
      filteredTasks = tasks.where((task) => !task.isCompleted).toList();
    } else {
      filteredTasks = tasks.where((task) => 
        task.list == listFilter && !task.isCompleted).toList();
    }

    final Map<String, List<Task>> grouped = {};

    // Initialize all time categories
    for (var category in CategoryConstants.timeCategoryOrder) {
      grouped[category] = [];
    }

    for (var task in filteredTasks) {
      final timeCategory = getTimeCategoryForTask(task);
      grouped[timeCategory]!.add(task);
    }

    // Remove empty categories
    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  /// Get the appropriate category for a task when it's completed
  /// This preserves the original category information
  String getCompletedTaskCategory(Task task) {
    return task.originalList.isNotEmpty ? task.originalList : task.list;
  }

  /// Check if a category name is valid for task assignment
  bool isValidCategoryForAssignment(String categoryName) {
    // Block reserved system names
    if (categoryName == CategoryConstants.completedCategoryName ||
        categoryName == CategoryConstants.allTasksCategoryName) {
      return false;
    }
    
    // Allow known default category
    if (categoryName == 'Công việc') {
      return true;
    }
    
    // Ensure exists among selectable categories
    final allCategories = getAllDisplayCategories();
    return allCategories.any((cat) => cat.name == categoryName && !cat.isSystem);
  }

  /// Get category display color
  Color getCategoryColor(String categoryName) {
    final category = getCategoryByName(categoryName);
    if (category != null) {
      return category.colorValue;
    }

    // Fallback to default grey
    return Colors.grey;
  }

  /// Get category icon
  IconData getCategoryIcon(String categoryName) {
    final category = getCategoryByName(categoryName);
    return category?.icon ?? Icons.folder;
  }

  /// Initialize default categories (call this once on app start)
  void initializeDefaultCategories() {
    // This could load custom categories from storage/database
    developer.log('Initializing category service with ${CategoryConstants.defaultCategories.length} default categories', 
                  name: 'CategoryService');
  }

  /// Clear all custom categories (for testing or reset)
  void clearCustomCategories() {
    _customCategories.clear();
  }
} 