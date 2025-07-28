import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String color;
  final bool isDefault;
  final bool isSystem;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.color,
    required this.isDefault,
    required this.isSystem,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Category copyWith({
    String? id,
    String? name,
    String? color,
    bool? isDefault,
    bool? isSystem,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      isSystem: isSystem ?? this.isSystem,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object> get props => [
    id,
    name,
    color,
    isDefault,
    isSystem,
    userId,
    createdAt,
    updatedAt,
  ];
} 