import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class ChangeTabEvent extends HomeEvent {
  final int index;

  const ChangeTabEvent(this.index);

  @override
  List<Object> get props => [index];
}

class ChangeCategoryEvent extends HomeEvent {
  final String categoryId;

  const ChangeCategoryEvent(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class LoadTasksEvent extends HomeEvent {
  const LoadTasksEvent();
}

class RefreshTasksEvent extends HomeEvent {
  const RefreshTasksEvent();
}
