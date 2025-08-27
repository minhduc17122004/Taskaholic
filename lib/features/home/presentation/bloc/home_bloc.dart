import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<ChangeTabEvent>(_onChangeTab);
    on<ChangeCategoryEvent>(_onChangeCategory);
  }

  void _onChangeTab(ChangeTabEvent event, Emitter<HomeState> emit) {
    if (event.index >= 0 && event.index <= 3 && event.index != state.currentIndex) {
      emit(state.copyWith(currentIndex: event.index));
    }
  }

  void _onChangeCategory(ChangeCategoryEvent event, Emitter<HomeState> emit) {
    if (event.categoryId != state.selectedCategoryId) {
      emit(state.copyWith(selectedCategoryId: event.categoryId));
    }
  }
}
