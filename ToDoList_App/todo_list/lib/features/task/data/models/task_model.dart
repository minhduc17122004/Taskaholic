import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
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

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle time field - can be either object {"hour": x, "minute": y} or string "HH:MM"
      TimeOfDay timeOfDay;
      if (json['time'] is Map<String, dynamic>) {
        // Object format: {"hour": 14, "minute": 30}
        final timeMap = json['time'] as Map<String, dynamic>;
        timeOfDay = TimeOfDay(
          hour: timeMap['hour'] as int,
          minute: timeMap['minute'] as int,
        );
      } else if (json['time'] is String) {
        // String format: "14:30"
        final timeString = json['time'] as String;
        final timeParts = timeString.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        timeOfDay = TimeOfDay(hour: hour, minute: minute);
      } else {
        // Fallback to current time if format is unexpected
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
        list: json['list']?.toString() ?? 'Mặc định',
        originalList: json['originalList']?.toString() ?? json['list']?.toString() ?? 'Mặc định',
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
        list: 'Mặc định',
        originalList: 'Mặc định',
        isCompleted: false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'time': {
        'hour': time.hour,
        'minute': time.minute,
      },
      'repeat': repeat,
      'list': list,
      'originalList': originalList,
      'isCompleted': isCompleted,
    };
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      date: entity.date,
      time: entity.time,
      repeat: entity.repeat,
      list: entity.list,
      originalList: entity.originalList,
      isCompleted: entity.isCompleted,
    );
  }
} 