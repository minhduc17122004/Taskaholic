import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final int currentIndex;
  final String selectedCategoryId;

  const HomeState({
    this.currentIndex = 0,
    this.selectedCategoryId = 'all', // Default to 'Tất cả'
  });

  HomeState copyWith({
    int? currentIndex,
    String? selectedCategoryId,
  }) {
    return HomeState(
      currentIndex: currentIndex ?? this.currentIndex,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }

  @override
  List<Object> get props => [currentIndex, selectedCategoryId];
}
