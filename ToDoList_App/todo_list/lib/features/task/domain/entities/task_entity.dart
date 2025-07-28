import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay time;
  final String repeat;
  final String list;
  final String originalList;
  final bool isCompleted;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.repeat,
    required this.list,
    required this.originalList,
    required this.isCompleted,
  });

  @override
  List<Object> get props => [
        id,
        title,
        date,
        time.hour,
        time.minute,
        repeat,
        list,
        originalList,
        isCompleted,
      ];

  TaskEntity copyWith({
    String? id,
    String? title,
    DateTime? date,
    TimeOfDay? time,
    String? repeat,
    String? list,
    String? originalList,
    bool? isCompleted,
  }) {
    return TaskEntity(
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

  bool get hasTime => time.hour > 0 || time.minute > 0;

  String getFormattedDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Hôm nay';
    } else if (taskDate == tomorrow) {
      return 'Ngày mai';
    } else {
      // Nếu task là trong tuần này (7 ngày tới)
      final difference = taskDate.difference(today).inDays;
      if (difference > 0 && difference < 7) {
        return DateFormat('EEEE', 'vi_VN').format(taskDate);
      } else {
        // Hiển thị ngày tháng năm đầy đủ cho các task xa hơn
        return DateFormat('dd/MM/yyyy', 'vi_VN').format(taskDate);
      }
    }
  }

  String get category {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);
    final endOfWeek = today.add(Duration(days: 7 - now.weekday));

    if (taskDate.isBefore(today)) {
      return 'Quá hạn';
    } else if (taskDate == today) {
      return 'Hôm nay';
    } else if (taskDate == tomorrow) {
      return 'Ngày mai';
    } else if (taskDate.isBefore(endOfWeek) || taskDate == endOfWeek) {
      return 'Tuần này';
    } else {
      return 'Sắp tới';
    }
  }
} 