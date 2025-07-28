import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
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

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      time: TimeOfDay(
        hour: json['time']['hour'],
        minute: json['time']['minute'],
      ),
      repeat: json['repeat'],
      list: json['list'],
      originalList: json['originalList'] ?? json['list'],
      isCompleted: json['isCompleted'],
    );
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