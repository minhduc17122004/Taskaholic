import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.date,
    super.time,
    required super.repeat,
    super.category,
    required super.isCompleted,
    required super.updatedAt,
    super.completedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      time: json['time'] != null 
          ? TimeOfDay(
              hour: json['time']['hour'],
              minute: json['time']['minute'],
            )
          : null,
      repeat: json['repeat'],
      category: json['category'],
      isCompleted: json['isCompleted'],
      updatedAt: DateTime.parse(json['updatedAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date?.toIso8601String(),
      'time': time != null 
          ? {
              'hour': time!.hour,
              'minute': time!.minute,
            }
          : null,
      'repeat': repeat,
      'category': category,
      'isCompleted': isCompleted,
      'updatedAt': updatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      date: entity.date,
      time: entity.time,
      repeat: entity.repeat,
      category: entity.category,
      isCompleted: entity.isCompleted,
      updatedAt: entity.updatedAt,
      completedAt: entity.completedAt,
    );
  }

  @override
  TaskModel copyWith({
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
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      repeat: repeat ?? this.repeat,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
