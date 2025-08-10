import 'package:equatable/equatable.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoriesLoaded extends CategoryState {
  final List<String> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
} 

class CategoryUpdated extends CategoryState {
  final String message;

  const CategoryUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryAdded extends CategoryState {
  final String message;

  const CategoryAdded(this.message);

  @override
  List<Object?> get props => [message];
} 