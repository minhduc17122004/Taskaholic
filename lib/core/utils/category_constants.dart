import 'package:flutter/material.dart';
import 'package:taskaholic/core/themes/app_color.dart';

/// Constants và utilities cho categories - extracted từ category_remote_datasource.dart
class CategoryConstants {
  // Danh sách categories mặc định từ remote datasource
  static const List<CategoryData> defaultCategories = [
    CategoryData(
      id: 'all',
      name: 'Tất cả',
      icon: Icons.all_inclusive,
      color: AppColors.primary,
    ),
    CategoryData(
      id: 'work',
      name: 'Công việc',
      icon: Icons.business_center,
      color: AppColors.categoryWork,
    ),
    CategoryData(
      id: 'personal',
      name: 'Cá nhân',
      icon: Icons.person,
      color: AppColors.categoryPersonal,
    ),
    CategoryData(
      id: 'study',
      name: 'Học tập',
      icon: Icons.school,
      color: AppColors.categoryStudy,
    ),
    CategoryData(
      id: 'health',
      name: 'Sức khỏe',
      icon: Icons.health_and_safety,
      color: AppColors.categoryHealth,
    ),
    CategoryData(
      id: 'shopping',
      name: 'Mua sắm',
      icon: Icons.shopping_cart,
      color: AppColors.categoryShopping,
    ),
  ];

  // Get category by ID
  static CategoryData? getCategoryById(String id) {
    try {
      return defaultCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category by name
  static CategoryData? getCategoryByName(String name) {
    try {
      return defaultCategories.firstWhere((cat) => cat.name == name);
    } catch (e) {
      return null;
    }
  }

  // Get only task categories (exclude 'all')
  static List<CategoryData> get taskCategories {
    return defaultCategories.where((cat) => cat.id != 'all').toList();
  }

  // Get category names only
  static List<String> get categoryNames {
    return defaultCategories.map((cat) => cat.name).toList();
  }

  // Get task category names only (exclude 'all')
  static List<String> get taskCategoryNames {
    return taskCategories.map((cat) => cat.name).toList();
  }
}

/// Data class cho category information
class CategoryData {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const CategoryData({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryData &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
