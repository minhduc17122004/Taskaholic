import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required String id,
    required String title,
    required DateTime date,
    required TimeOfDay time,
    required String repeat,
    required String list,
    required String originalList,
    required bool isCompleted,
  }) : super(
          id: id,
          title: title,
          date: date,
          time: time,
          repeat: repeat,
          list: list,
          originalList: originalList,
          isCompleted: isCompleted,
        );

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
    final timeString = json['time'] as String;
    final timeParts = timeString.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return TaskModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'],
      date: DateTime.parse(json['date']),
      time: TimeOfDay(hour: hour, minute: minute),
      repeat: json['repeat'],
      list: json['list'],
      originalList: json['originalList'] ?? json['list'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'repeat': repeat,
      'list': list,
      'originalList': originalList,
      'isCompleted': isCompleted,
    };
  }

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