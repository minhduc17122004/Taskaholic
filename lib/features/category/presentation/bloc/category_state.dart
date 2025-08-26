part of 'category_bloc.dart';

@immutable
sealed class CategoryState {}

final class CategoryInitial extends CategoryState {}

final class CategoryLoading extends CategoryState {}

final class CategoriesLoaded extends CategoryState {
  final List<CategoryEntity> categories;
  final List<CategoryEntity> filteredCategories;

  CategoriesLoaded({
    required this.categories,
    List<CategoryEntity>? filteredCategories,
  }) : filteredCategories = filteredCategories ?? categories;

  CategoriesLoaded copyWith({
    List<CategoryEntity>? categories,
    List<CategoryEntity>? filteredCategories,
  }) {
    return CategoriesLoaded(
      categories: categories ?? this.categories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
    );
  }
}

final class CategoryError extends CategoryState {
  final String message;

  CategoryError(this.message);
}

final class CategoryAdded extends CategoryState {
  final CategoryEntity category;

  CategoryAdded(this.category);
}

final class CategoryUpdated extends CategoryState {
  final CategoryEntity category;

  CategoryUpdated(this.category);
}

final class CategoryDeleted extends CategoryState {
  final String categoryId;

  CategoryDeleted(this.categoryId);
}
