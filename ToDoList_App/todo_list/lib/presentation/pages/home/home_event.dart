import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {
  const LoadHomeDataEvent();
}

class ChangeCurrentListEvent extends HomeEvent {
  final String listName;

  const ChangeCurrentListEvent(this.listName);

  @override
  List<Object?> get props => [listName];
}

class ChangeTabEvent extends HomeEvent {
  final int index;

  const ChangeTabEvent(this.index);

  @override
  List<Object?> get props => [index];
} 