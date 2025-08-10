import 'package:flutter/material.dart';

/// Constants and utilities for managing task categories
class CategoryConstants {
  // System category IDs (not selectable by users)
  static const String completedCategoryId = 'system_completed';
  static const String allTasksCategoryId = 'system_all_tasks';
  
  // System category names
  static const String completedCategoryName = 'Đã hoàn thành';
  static const String allTasksCategoryName = 'Danh sách tất cả';
  
  // Default user categories
  static const List<CategoryInfo> defaultCategories = [
    CategoryInfo(
      id: 'work',
      name: 'Công việc',
      color: '#2196F3',
      icon: Icons.work,
      isSystem: false,
    ),
    CategoryInfo(
      id: 'personal',
      name: 'Cá nhân',
      color: '#4CAF50',
      icon: Icons.person,
      isSystem: false,
    ),
    CategoryInfo(
      id: 'study',
      name: 'Học tập',
      color: '#FF9800',
      icon: Icons.school,
      isSystem: false,
    ),
    CategoryInfo(
      id: 'health',
      name: 'Sức khỏe',
      color: '#E91E63',
      icon: Icons.favorite,
      isSystem: false,
    ),
    CategoryInfo(
      id: 'shopping',
      name: 'Mua sắm',
      color: '#9C27B0',
      icon: Icons.shopping_cart,
      isSystem: false,
    ),
  ];
  
  // System categories (not selectable for task assignment)
  static const List<CategoryInfo> systemCategories = [
    CategoryInfo(
      id: completedCategoryId,
      name: completedCategoryName,
      color: '#4CAF50',
      icon: Icons.check_circle,
      isSystem: true,
    ),
    CategoryInfo(
      id: allTasksCategoryId,
      name: allTasksCategoryName,
      color: '#2196F3',
      icon: Icons.list,
      isSystem: true,
    ),
  ];
  
  // Time-based categories for display
  static const List<String> timeCategoryOrder = [
    'Quá hạn',
    'Hôm nay',
    'Ngày mai',
    'Tuần này',
    'Không có ngày',
    'Sắp tới',
  ];
  
  /// Get all categories (default + system)
  static List<CategoryInfo> getAllCategories() {
    return [...defaultCategories, ...systemCategories];
  }
  
  /// Get only user-selectable categories (excludes system categories)
  static List<CategoryInfo> getSelectableCategories() {
    return defaultCategories.where((cat) => !cat.isSystem).toList();
  }
  
  /// Get category by ID
  static CategoryInfo? getCategoryById(String id) {
    if (id.isEmpty) return null;
    
    try {
      final matches = getAllCategories().where((cat) => cat.id == id);
      return matches.isNotEmpty ? matches.first : null;
    } catch (e) {
      return null;
    }
  }
  
  /// Get category by name
  static CategoryInfo? getCategoryByName(String name) {
    if (name.isEmpty) return null;
    
    try {
      final matches = getAllCategories().where((cat) => cat.name == name);
      return matches.isNotEmpty ? matches.first : null;
    } catch (e) {
      return null;
    }
  }
  
  /// Check if a category is system category by ID
  static bool isSystemCategoryId(String categoryId) {
    return systemCategories.any((cat) => cat.id == categoryId);
  }
}

/// Category information model
class CategoryInfo {
  final String id;
  final String name;
  final String color;
  final IconData icon;
  final bool isSystem;
  
  const CategoryInfo({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.isSystem,
  });
  
  /// Convert hex color string to Color
  Color get colorValue {
    return Color(int.parse(color.substring(1), radix: 16) + 0xFF000000);
  }
  
  /// Create a copy with modified values
  CategoryInfo copyWith({
    String? id,
    String? name,
    String? color,
    IconData? icon,
    bool? isSystem,
  }) {
    return CategoryInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isSystem: isSystem ?? this.isSystem,
    );
  }
} 