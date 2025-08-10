import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    required super.date,
    required super.time,
    required super.repeat,
    required super.list,
    required super.originalList,
    required super.isCompleted,
  });

  factory TaskModel.fromEntity(Task task) => TaskModel(
        id: task.id,
        title: task.title,
        date: task.date,
        time: task.time,
        repeat: task.repeat,
        list: task.list,
        originalList: task.originalList,
        isCompleted: task.isCompleted,
      );

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle time field - can be either string "HH:MM" or object {"hour": x, "minute": y}
      TimeOfDay timeOfDay;
      if (json['time'] is String) {
        final timeString = json['time'] as String;
        if (timeString == '0:0') {
          timeOfDay = const TimeOfDay(hour: 0, minute: 0);
        } else {
          final timeParts = timeString.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          timeOfDay = TimeOfDay(hour: hour, minute: minute);
        }
      } else if (json['time'] is Map<String, dynamic>) {
        final timeMap = json['time'] as Map<String, dynamic>;
        timeOfDay = TimeOfDay(
          hour: timeMap['hour'] as int,
          minute: timeMap['minute'] as int,
        );
      } else {
        final now = TimeOfDay.now();
        timeOfDay = now;
        debugPrint('Warning: Unexpected time format in JSON, using current time: ${json['time']}');
      }

      return TaskModel(
        id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title']?.toString() ?? '',
        date: json['date'] is String ? DateTime.parse(json['date']) : (json['date'] as DateTime? ?? DateTime.now()),
        time: timeOfDay,
        repeat: json['repeat']?.toString() ?? 'Không lặp lại',
        list: json['list']?.toString() ?? 'Công việc',
        originalList: json['originalList']?.toString() ?? json['list']?.toString() ?? 'Công việc',
        isCompleted: json['isCompleted'] is bool ? json['isCompleted'] : (json['isCompleted']?.toString() == 'true'),
      );
    } catch (e) {
      debugPrint('Error parsing TaskModel from JSON: $e');
      debugPrint('JSON data: $json');
      
      // Return a default task with minimal data
      return TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title']?.toString() ?? 'Untitled Task',
        date: DateTime.now(),
        time: TimeOfDay.now(),
        repeat: 'Không lặp lại',
        list: 'Công việc',
        originalList: 'Công việc',
        isCompleted: false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'time': '$hh:$mm',
      'repeat': repeat,
      'list': list,
      'originalList': originalList,
      'isCompleted': isCompleted,
    };
  }

  @override
  TaskModel copyWith({
    String? id,
    String? title,
    DateTime? date,
    TimeOfDay? time,
    String? repeat,
    String? list,
    String? originalList,
    bool? isCompleted,
  }) {
    return TaskModel(
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
} 