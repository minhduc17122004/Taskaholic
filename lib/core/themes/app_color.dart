import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color error = Color(0xFFB00020);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  

  // Dark theme colors
  static const Color primaryDark = Color(0xFF01639B);
  static const Color secondaryDark = Color(0xFF018A94);
  static const Color backgroundDark = Color(0xFF002D51);
  static const Color cardBackgroundDark = Color(0xFF013F71);
  static const Color borderDark = Color(0xFF01639B);
  
  // Text colors (Light theme)
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Text colors (Dark theme)
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFBBBBBB);
  
  // Input colors (Light theme)
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFBDBDBD);
  static const Color border = Color(0xFFBDBDBD);
  
  // Input colors (Dark theme)
  static const Color inputBackgroundDark = Color(0xFF014F8A);
  static const Color inputBackgroundDark2 = Color.fromARGB(255, 0, 30, 60);
  
  // Button colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = Color(0xFFE3F2FD);
  static const Color buttonDisabled = Color(0xFFE0E0E0);

  // status colors
  static const Color overdue = Color(0xFFF44336);
  static const Color today = Color(0xFF4CAF50);
  static const Color upcoming = Color(0xFF2196F3);
  static const Color completed = Color(0xFF4CAF50);
  static const Color pending = Color(0xFFFFC107);
  static const Color cancelled = Color(0xFF9E9E9E);
  static const Color archived = Color(0xFF607D8B);
  static const Color deleted = Color(0xFFF44336);
  static const Color important = Color(0xFFF44336);
  // Category colors - Predefined colors for different category types
  static const Color categoryWork = Color(0xFF2196F3);      // Blue - Professional
  static const Color categoryPersonal = Color(0xFF4CAF50);  // Green - Life
  static const Color categoryStudy = Color(0xFFFF9800);     // Orange - Learning
  static const Color categoryHealth = Color(0xFFE91E63);    // Pink - Wellness
  static const Color categoryShopping = Color(0xFF9C27B0);  // Purple - Commerce
  static const Color categoryFinance = Color(0xFF00BCD4);   // Cyan - Money
  static const Color categoryFamily = Color(0xFFFFEB3B);    // Yellow - Warmth
  static const Color categoryTravel = Color(0xFF795548);    // Brown - Adventure
  static const Color categoryHobbies = Color(0xFF607D8B);   // Blue Grey - Leisure
  static const Color categoryDefault = Color(0xFF9E9E9E);   // Grey - Default
  
  // Available category colors for user selection
  static const List<Color> availableCategoryColors = [
    categoryWork,      // Blue
    categoryPersonal,  // Green  
    categoryStudy,     // Orange
    categoryHealth,    // Pink
    categoryShopping,  // Purple
    categoryFinance,   // Cyan
    categoryFamily,    // Yellow
    categoryTravel,    // Brown
    categoryHobbies,   // Blue Grey
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF3F51B5), // Indigo
    Color(0xFF009688), // Teal
    Color(0xFFCDDC39), // Lime
    Color(0xFFFFC107), // Amber
    Color(0xFF673AB7), // Deep Purple
    Color(0xFFE4C441), // Gold
  ];
  
  // Get color by category name (Vietnamese)
  static Color getCategoryColorByName(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'công việc':
      case 'work':
        return categoryWork;
      case 'cá nhân':
      case 'personal':
        return categoryPersonal;
      case 'học tập':
      case 'study':
      case 'education':
        return categoryStudy;
      case 'sức khỏe':
      case 'health':
      case 'wellness':
        return categoryHealth;
      case 'mua sắm':
      case 'shopping':
        return categoryShopping;
      case 'tài chính':
      case 'finance':
        return categoryFinance;
      case 'gia đình':
      case 'family':
        return categoryFamily;
      case 'du lịch':
      case 'travel':
        return categoryTravel;
      case 'sở thích':
      case 'hobbies':
        return categoryHobbies;
      default:
        return categoryDefault;
    }
  }
  
  // Convert Color to hex string for storage
  static String colorToHex(Color color) {
    // ignore: deprecated_member_use
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
  
  // Convert hex string to Color
  static Color hexToColor(String hexString) {
    try {
      final hex = hexString.replaceFirst('#', '');
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return categoryDefault;
    }
  }
}