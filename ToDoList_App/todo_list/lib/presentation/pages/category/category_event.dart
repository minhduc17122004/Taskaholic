import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategoriesEvent extends CategoryEvent {
  const LoadCategoriesEvent();
}

class AddCategoryEvent extends CategoryEvent {
  final String name;

  const AddCategoryEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class DeleteCategoryEvent extends CategoryEvent {
  final String name;

  const DeleteCategoryEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class EditCategoryEvent extends CategoryEvent {
  final String oldName;
  final String newName;

  const EditCategoryEvent(this.oldName, this.newName);

  @override
  List<Object?> get props => [oldName, newName];
} 

class SearchCategoriesEvent extends CategoryEvent {
  final String query;

  const SearchCategoriesEvent(this.query);

  @override
  List<Object?> get props => [query];
} 