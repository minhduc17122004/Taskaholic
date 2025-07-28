import 'package:flutter/material.dart';

class DateFormatUtils {
  // Danh sách các ngày trong tuần
  static const List<String> weekdays = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'CN',
  ];

  // Danh sách các tháng
  static const List<String> months = [
    'Tháng 1',
    'Tháng 2',
    'Tháng 3',
    'Tháng 4',
    'Tháng 5',
    'Tháng 6',
    'Tháng 7',
    'Tháng 8',
    'Tháng 9',
    'Tháng 10',
    'Tháng 11',
    'Tháng 12',
  ];

  // Hàm định dạng ngày tháng
  static String formatDate(DateTime date) {
    String weekday = weekdays[date.weekday - 1]; // Thứ 2 là 1, CN là 7
    String month = months[date.month - 1];
    int day = date.day;
    int year = date.year;

    return '$weekday, ngày $day $month, $year';
  }

  // Phương thức chọn ngày
  static Future<DateTime?> selectDate({
    required BuildContext context,
    DateTime? initialDate,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            // Chọn chủ đề sáng
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Màu chủ đạo
              onPrimary: Colors.white, // Màu chữ trên nền chính
              surface: Colors.white, // Màu nền
            ),
          ),
          child: child!,
        );
      },
    );
  }

  // Phương thức chọn giờ
  static Future<TimeOfDay?> selectTime({
    required BuildContext context,
    TimeOfDay? initialTime,
  }) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
