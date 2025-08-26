part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategoriesEvent extends CategoryEvent {
  const LoadCategoriesEvent();
}

class AddCategoryEvent extends CategoryEvent {
  final CategoryEntity category;

  const AddCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategoryEvent extends CategoryEvent {
  final String categoryId;

  const DeleteCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class UpdateCategoryEvent extends CategoryEvent {
  final CategoryEntity category;

  const UpdateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
} 

class SearchCategoriesEvent extends CategoryEvent {
  final String query;

  const SearchCategoriesEvent(this.query);

  @override
  List<Object?> get props => [query];
} 
