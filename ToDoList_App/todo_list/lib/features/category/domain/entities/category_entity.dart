import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final int taskCount;
  final bool isSystem;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.taskCount = 0,
    this.isSystem = false,
  });

  @override
  List<Object> get props => [id, name, taskCount, isSystem];

  CategoryEntity copyWith({
    String? id,
    String? name,
    int? taskCount,
    bool? isSystem,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      taskCount: taskCount ?? this.taskCount,
      isSystem: isSystem ?? this.isSystem,
    );
  }
} 