import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required String id,
    required String name,
    int taskCount = 0,
    bool isSystem = false,
  }) : super(
          id: id,
          name: name,
          taskCount: taskCount,
          isSystem: isSystem,
        );

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      taskCount: json['taskCount'] ?? 0,
      isSystem: json['isSystem'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'taskCount': taskCount,
      'isSystem': isSystem,
    };
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      taskCount: entity.taskCount,
      isSystem: entity.isSystem,
    );
  }
} 