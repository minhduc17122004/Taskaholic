import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../../task/domain/usecases/get_tasks.dart';
import '../../../../core/usecases/usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetTasks getTasks;

  HomeBloc({
    required this.getTasks,
  }) : super(const HomeInitial()) {
    on<ChangeTabEvent>(_onChangeTab);
    on<ChangeCategoryEvent>(_onChangeCategory);
    on<LoadTasksEvent>(_onLoadTasks);
    on<RefreshTasksEvent>(_onRefreshTasks);
  }

  void _onChangeTab(ChangeTabEvent event, Emitter<HomeState> emit) {
    final currentState = state;
    if (event.index >= 0 && event.index <= 3) {
      if (currentState is HomeInitial) {
        emit(currentState.copyWith(currentIndex: event.index));
      } else if (currentState is HomeLoaded) {
        emit(currentState.copyWith(currentIndex: event.index));
      }
    }
  }

  void _onChangeCategory(ChangeCategoryEvent event, Emitter<HomeState> emit) {
    final currentState = state;
    if (currentState is HomeInitial) {
      emit(currentState.copyWith(selectedCategoryId: event.categoryId));
    } else if (currentState is HomeLoaded) {
      emit(currentState.copyWith(selectedCategoryId: event.categoryId));
    }
  }

  Future<void> _onLoadTasks(LoadTasksEvent event, Emitter<HomeState> emit) async {
    final currentState = state;
    final currentIndex = currentState is HomeInitial ? currentState.currentIndex :
                        currentState is HomeLoaded ? currentState.currentIndex : 0;
    final selectedCategoryId = currentState is HomeInitial ? currentState.selectedCategoryId :
                              currentState is HomeLoaded ? currentState.selectedCategoryId : 'all';

    emit(HomeLoading(
      currentIndex: currentIndex,
      selectedCategoryId: selectedCategoryId,
    ));

    try {
      final result = await getTasks(NoParams());
      
      result.fold(
        (failure) {
          developer.log('Lỗi khi tải danh sách công việc: ${failure.message}', name: 'HomeBloc');
          emit(HomeError(
            currentIndex: currentIndex,
            selectedCategoryId: selectedCategoryId,
            message: failure.message,
          ));
        },
        (allTasks) {
          final tasks = allTasks.where((task) => !task.isCompleted).toList();
          final completedTasks = allTasks.where((task) => task.isCompleted).toList();
          
          emit(HomeLoaded(
            currentIndex: currentIndex,
            selectedCategoryId: selectedCategoryId,
            tasks: tasks,
            completedTasks: completedTasks,
          ));
        },
      );
    } catch (e) {
      developer.log('Lỗi không xác định khi tải danh sách công việc: $e', name: 'HomeBloc');
      emit(HomeError(
        currentIndex: currentIndex,
        selectedCategoryId: selectedCategoryId,
        message: 'Không thể tải danh sách công việc: $e',
      ));
    }
  }

  Future<void> _onRefreshTasks(RefreshTasksEvent event, Emitter<HomeState> emit) async {
    // Refresh without showing loading state
    final currentState = state;
    if (currentState is HomeLoaded) {
      try {
        final result = await getTasks(NoParams());
        
        result.fold(
          (failure) {
            developer.log('Lỗi khi refresh danh sách công việc: ${failure.message}', name: 'HomeBloc');
            // Keep current state on error
          },
          (allTasks) {
            final tasks = allTasks.where((task) => !task.isCompleted).toList();
            final completedTasks = allTasks.where((task) => task.isCompleted).toList();
            
            emit(currentState.copyWith(
              tasks: tasks,
              completedTasks: completedTasks,
            ));
          },
        );
      } catch (e) {
        developer.log('Lỗi không xác định khi refresh danh sách công việc: $e', name: 'HomeBloc');
        // Keep current state on error
      }
    } else {
      // If not loaded yet, do a full load
      add(const LoadTasksEvent());
    }
  }
}
