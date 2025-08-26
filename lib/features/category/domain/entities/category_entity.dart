import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int taskCount;
  final bool isSystem;
  final Color color;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.createdAt,
    this.updatedAt,
    required this.taskCount,
    this.isSystem = false,
    required this.color,
  });

  @override
  List<Object> get props => [id, name, taskCount, isSystem, color];

  CategoryEntity copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? taskCount,
    bool? isSystem,
    Color? color,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      taskCount: taskCount ?? this.taskCount,
      isSystem: isSystem ?? this.isSystem,
      color: color ?? this.color,
    );
  }
} 