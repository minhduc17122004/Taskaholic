import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:taskaholic/core/utils/date_fomatter.dart';

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final DateTime? date;
  final TimeOfDay? time;
  final String repeat;
  final String? category;
  final bool isCompleted;
  final DateTime updatedAt;
  final DateTime? completedAt;


  const TaskEntity({
    required this.id,
    required this.title,
    this.date,
    this.time,
    required this.repeat,
    this.category,
    required this.isCompleted,
    required this.updatedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        date,
        time?.hour,
        time?.minute,
        repeat,
        category,
        isCompleted,
        updatedAt,
        completedAt,
      ];

  TaskEntity copyWith({
    String? id,
    String? title,
    DateTime? date,
    TimeOfDay? time,
    String? repeat,
    String? category,
    bool? isCompleted,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      repeat: repeat ?? this.repeat,
      category: category?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool get hasTime => time?.hour != null && time?.minute != null;

  /// Lấy thời gian formatted dạng HH:mm (24h format)
  String getFormattedTime() {
    if (time == null) return 'Không có giờ';
    
    final hour = time!.hour.toString().padLeft(2, '0');
    final minute = time!.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Lấy thời gian formatted dạng 12h (AM/PM)
  String getFormattedTime12H() {
    if (time == null) return 'Không có giờ';
    
    final hour = time!.hour;
    final minute = time!.minute;
    final period = hour < 12 ? 'SA' : 'CH';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    
    return '$displayHour:$minuteStr $period';
  }

  /// Lấy ngày và giờ đầy đủ
  String getFormattedDateTime() {
    final dateStr = getFormattedDate();
    final timeStr = getFormattedTime();
    
    if (date == null && time == null) {
      return 'Không có thời gian';
    } else if (date == null) {
      return timeStr;
    } else if (time == null) {
      return dateStr;
    } else {
      return '$dateStr lúc $timeStr';
    }
  }

  /// Lấy TimeOfDay object (có thể null)
  TimeOfDay? getTime() => time;

  /// Lấy giờ (0-23), trả về null nếu không có thời gian
  int? getHour() => time?.hour;

  /// Lấy phút (0-59), trả về null nếu không có thời gian  
  int? getMinute() => time?.minute;

  String getFormattedDate() {
    if (date == null) return 'Không có ngày';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date!.year, date!.month, date!.day);

    if (taskDate == today) return 'Hôm nay';
    if (taskDate == tomorrow) return 'Ngày mai';

    final diff = taskDate.difference(today).inDays;
    if (diff > 0 && diff < 7) {
      return formatTaskDate(taskDate);
    }

    return formatTaskDate(taskDate);
  }

  String getTaskDate() {
    if (date == null) return 'Không có ngày';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date!.year, date!.month, date!.day);
    final endOfWeek = today.add(Duration(days: 7 - now.weekday));
    final endOfMonth = today.add(Duration(days: 30));
    final endOfYear = today.add(Duration(days: 365));
    final afterEndOfWeek = endOfWeek.add(const Duration(days: 1));
    final afterEndOfMonth = endOfMonth.add(const Duration(days: 1));
    final afterEndOfYear = endOfYear.add(const Duration(days: 1));
    
    if (taskDate.isBefore(today)) return 'Quá hạn';
    if (taskDate.isAtSameMomentAs(today)) return 'Hôm nay';
    if (taskDate.isAtSameMomentAs(tomorrow)) return 'Ngày mai';
    if (taskDate.isBefore(afterEndOfWeek)) return 'Tuần này';
    if (taskDate.isBefore(afterEndOfWeek.add(const Duration(days: 1)))) return 'Tuần tới';
    if (taskDate.isBefore(afterEndOfMonth)) return 'Tháng tới';
    if (taskDate.isBefore(afterEndOfYear)) return 'Năm tới';
   
    return 'Không có ngày';
  }
}
