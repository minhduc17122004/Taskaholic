import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taskaholic/core/themes/app_color.dart';
import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.createdAt,
    super.updatedAt,
    super.taskCount = 0,
    super.isSystem = false,
    required super.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final categoryName = json['name'] ?? 'Untitled Category';
    return CategoryModel(
      id: json['id'],
      name: categoryName,
      createdAt: _parseTimestamp(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseTimestamp(json['updatedAt']),
      taskCount: json['taskCount'] ?? 0,
      isSystem: json['isSystem'] ?? false,
      color: json['color'] != null 
          ? AppColors.hexToColor(json['color'])
          : AppColors.getCategoryColorByName(categoryName),
    );
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'taskCount': taskCount,
      'isSystem': isSystem,
      'color': AppColors.colorToHex(color),
    };
  }

  @override
  CategoryModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? taskCount,
    bool? isSystem,
    Color? color,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      taskCount: taskCount ?? this.taskCount,
      isSystem: isSystem ?? this.isSystem,
      color: color ?? this.color,
    );
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      taskCount: entity.taskCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSystem: entity.isSystem,
      color: entity.color,
    );
  }

  /// Tạo map data với server timestamps cho category mới
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'taskCount': taskCount,
      'isSystem': isSystem,
      'color': AppColors.colorToHex(color),
    };
  }

  /// Tạo map data với server timestamp cho việc cập nhật
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
      'taskCount': taskCount,
      'isSystem': isSystem,
      'color': AppColors.colorToHex(color),
    };
  }
} 