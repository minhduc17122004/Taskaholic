class TaskDateUtils {
  // Extract từ task_group.dart - logic đã có sẵn
  static String getFormattedDate([DateTime? date]) {
    final now = date ?? DateTime.now();
    final weekday = ['Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy'][now.weekday % 7];
    return '$weekday, ${now.day}/${now.month}/${now.year}';
  }

  // Helper methods để classify date categories - dựa trên logic có sẵn trong task_group.dart  
  static String getDateCategory(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final inputDate = DateTime(date.year, date.month, date.day);
    
    if (inputDate.isBefore(today)) {
      return 'Quá hạn';
    } else if (inputDate == today) {
      return 'Hôm nay';
    } else if (inputDate == today.add(const Duration(days: 1))) {
      return 'Ngày mai';
    } else if (inputDate.isBefore(today.add(const Duration(days: 7)))) {
      return 'Tuần này';
    } else {
      return 'Sắp tới';
    }
  }

  // Categories đã có sẵn trong task_group.dart
  static const List<String> predefinedCategories = [
    'Quá hạn',
    'Hôm nay', 
    'Ngày mai',
    'Tuần này',
    'Không có ngày',
  ];

  static String formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
