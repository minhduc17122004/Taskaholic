import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required String id,
    required String name,
    required String color,
    required bool isDefault,
    required bool isSystem,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          name: name,
          color: color,
          isDefault: isDefault,
          isSystem: isSystem,
          userId: userId,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      isDefault: json['isDefault'] as bool,
      isSystem: json['isSystem'] as bool,
      userId: json['userId'] as String,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is DateTime
              ? json['createdAt']
              : DateTime.parse(json['createdAt']))
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is DateTime
              ? json['updatedAt']
              : DateTime.parse(json['updatedAt']))
          : DateTime.now(),
    );
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      color: category.color,
      isDefault: category.isDefault,
      isSystem: category.isSystem,
      userId: category.userId,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'isDefault': isDefault,
      'isSystem': isSystem,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 