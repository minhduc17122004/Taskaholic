import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay time;
  final String repeat;
  final String list;
  final String originalList;
  final bool isCompleted;

  const Task({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.repeat,
    required this.list,
    required this.originalList,
    required this.isCompleted,
  });

  Task copyWith({
    String? id,
    String? title,
    DateTime? date,
    TimeOfDay? time,
    String? repeat,
    String? list,
    String? originalList,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      repeat: repeat ?? this.repeat,
      list: list ?? this.list,
      originalList: originalList ?? this.originalList,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Kiểm tra xem task có thời gian hay không
  bool get hasTime => !(time.hour == 0 && time.minute == 0);

  // Lấy danh mục của task dựa vào ngày (quá hạn, hôm nay, ngày mai, tuần này)
  String get category {
    // Nếu task thuộc danh sách Mặc định, gán danh mục là "Không có ngày"
    if (list == 'Mặc định') {
      return 'Không có ngày';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(date.year, date.month, date.day);

    // Nếu ngày của task trước ngày hiện tại, task đã quá hạn
    if (taskDay.isBefore(today)) {
      return 'Quá hạn';
    }
    // Nếu ngày của task là ngày hiện tại
    else if (taskDay.isAtSameMomentAs(today)) {
      // Kiểm tra thêm thời gian nếu task có thời gian
      if (hasTime) {
        // Lấy thời gian hiện tại
        final currentHour = now.hour;
        final currentMinute = now.minute;

        // Nếu thời gian của task đã qua so với thời gian hiện tại
        if (time.hour < currentHour ||
            (time.hour == currentHour && time.minute < currentMinute)) {
          return 'Quá hạn';
        }
      }
      return 'Hôm nay';
    } else if (taskDay.difference(today).inDays == 1) {
      return 'Ngày mai';
    } else if (taskDay.difference(today).inDays < 7) {
      return 'Tuần này';
    } else {
      return 'Sắp tới';
    }
  }

  // Format thời gian để hiển thị (VD: 12:00)
  String getFormattedTime(BuildContext context) {
    // Nếu task không có thời gian, trả về chuỗi rỗng
    if (!hasTime) {
      return '';
    }
    return time.format(context);
  }

  // Format ngày để hiển thị (VD: Hôm nay, 12:00)
  String getFormattedDate() {
    // Nếu task thuộc danh sách Mặc định, không hiển thị ngày
    if (list == 'Mặc định') {
      return '';
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDay = DateTime(date.year, date.month, date.day);

    if (taskDay.isAtSameMomentAs(today)) {
      // nếu taskDay là hôm nay
      return 'Hôm nay';
    } else if (taskDay.isAtSameMomentAs(tomorrow)) {
      // nếu taskDay là ngày mai
      return 'Ngày mai';
    } else {
      // Kiểm tra nếu trong tuần này (7 ngày)
      final daysDifference = taskDay.difference(today).inDays;
      if (daysDifference < 7) {
        // Lấy tên thứ trong tuần
        final weekdays = [
          'Thứ 2',
          'Thứ 3',
          'Thứ 4',
          'Thứ 5',
          'Thứ 6',
          'Thứ 7',
          'CN',
        ];
        return weekdays[date.weekday - 1]; // Thứ 2 là 1, CN là 7
      } else {
        // Hiển thị ngày/tháng/năm cho các ngày xa hơn
        return '${date.day}/${date.month}/${date.year}';
      }
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        date,
        time,
        repeat,
        list,
        originalList,
        isCompleted,
      ];
} 