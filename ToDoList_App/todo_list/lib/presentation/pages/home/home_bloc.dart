import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/lists_data.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<ChangeCurrentListEvent>(_onChangeCurrentList);
    on<ChangeTabEvent>(_onChangeTab);
  }

  void _onLoadHomeData(LoadHomeDataEvent event, Emitter<HomeState> emit) {
    emit(HomeLoading());
    
    try {
      final availableLists = ListsData.getNavigationCategories();
      const defaultList = 'Danh sách tất cả';
      const defaultIndex = 0; // Tab Home
      
      emit(HomeLoaded(
        currentList: defaultList,
        currentIndex: defaultIndex,
        availableLists: availableLists,
      ));
    } catch (e) {
      developer.log('Lỗi khi tải dữ liệu Home: $e', name: 'HomeBloc');
      emit(HomeError('Không thể tải dữ liệu Home: $e'));
    }
  }

  void _onChangeCurrentList(ChangeCurrentListEvent event, Emitter<HomeState> emit) {
    try {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(currentState.copyWith(currentList: event.listName));
      }
    } catch (e) {
      developer.log('Lỗi khi thay đổi danh sách: $e', name: 'HomeBloc');
      emit(HomeError('Không thể thay đổi danh sách: $e'));
    }
  }

  void _onChangeTab(ChangeTabEvent event, Emitter<HomeState> emit) {
    try {
      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(currentState.copyWith(currentIndex: event.index));
      }
    } catch (e) {
      developer.log('Lỗi khi thay đổi tab: $e', name: 'HomeBloc');
      emit(HomeError('Không thể thay đổi tab: $e'));
    }
  }
} 