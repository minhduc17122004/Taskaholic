import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String currentList;
  final int currentIndex;
  final List<String> availableLists;

  const HomeLoaded({
    required this.currentList,
    required this.currentIndex,
    required this.availableLists,
  });

  @override
  List<Object?> get props => [currentList, currentIndex, availableLists];

  HomeLoaded copyWith({
    String? currentList,
    int? currentIndex,
    List<String>? availableLists,
  }) {
    return HomeLoaded(
      currentList: currentList ?? this.currentList,
      currentIndex: currentIndex ?? this.currentIndex,
      availableLists: availableLists ?? this.availableLists,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
} 