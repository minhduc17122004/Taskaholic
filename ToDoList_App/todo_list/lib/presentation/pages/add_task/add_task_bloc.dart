import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../data/lists_data.dart';
import '../../../domain/entities/task.dart'; // Cần cập nhật thành TaskEntity
import '../../../domain/usecases/add_task.dart';
import '../../../domain/usecases/delete_task.dart';
import '../../../domain/usecases/update_task.dart';
import 'add_task_event.dart';
import 'add_task_state.dart';

class AddTaskBloc extends Bloc<AddTaskEvent, AddTaskState> {
  final AddTask addTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;

  AddTaskBloc({
    required this.addTask,
    required this.updateTask,
    required this.deleteTask,
  }) : super(AddTaskInitial()) {
    on<InitializeAddTaskEvent>(_onInitialize);
    on<ChangeDateEvent>(_onChangeDate);
    on<ChangeTimeEvent>(_onChangeTime);
    on<ChangeRepeatEvent>(_onChangeRepeat);
    on<ChangeListEvent>(_onChangeList);
    on<SaveTaskEvent>(_onSaveTask);
    on<DeleteTaskEvent>(_onDeleteTask);
  }

  void _onInitialize(InitializeAddTaskEvent event, Emitter<AddTaskState> emit) {
    emit(AddTaskLoading());

    try {
      final availableLists = ListsData.getAddTaskListOptions();
      String selectedList;

      if (event.existingTask != null) {
        // Chỉnh sửa task hiện có
        final task = event.existingTask!;
        selectedList = task.list;

        // Đảm bảo danh sách đã chọn có trong các tùy chọn
        if (!availableLists.contains(selectedList)) {
          availableLists.add(selectedList);
        }

        emit(AddTaskFormState(
          taskId: task.id,
          title: task.title,
          selectedDate: task.date,
          selectedTime: task.time,
          selectedRepeat: task.repeat,
          selectedList: selectedList,
          availableLists: availableLists,
          isEditing: true,
        ));
      } else {
        // Tạo task mới
        selectedList = event.initialList ?? 
            (availableLists.isNotEmpty ? availableLists[0] : 'Công việc');

        emit(AddTaskFormState(
          selectedList: selectedList,
          availableLists: availableLists,
        ));
      }
    } catch (e) {
      developer.log('Lỗi khi khởi tạo form: $e', name: 'AddTaskBloc');
      emit(AddTaskError('Không thể khởi tạo form: $e'));
    }
  }

  void _onChangeDate(ChangeDateEvent event, Emitter<AddTaskState> emit) {
    if (state is AddTaskFormState) {
      final currentState = state as AddTaskFormState;
      emit(currentState.copyWith(selectedDate: event.date));
    }
  }

  void _onChangeTime(ChangeTimeEvent event, Emitter<AddTaskState> emit) {
    if (state is AddTaskFormState) {
      final currentState = state as AddTaskFormState;
      emit(currentState.copyWith(selectedTime: event.time));
    }
  }

  void _onChangeRepeat(ChangeRepeatEvent event, Emitter<AddTaskState> emit) {
    if (state is AddTaskFormState) {
      final currentState = state as AddTaskFormState;
      
      // Nếu là tùy chọn "Khác...", không thay đổi state ở đây
      // vì sẽ được xử lý bởi dialog tùy chỉnh
      if (event.repeat != 'Khác...') {
        emit(currentState.copyWith(selectedRepeat: event.repeat));
      }
    }
  }

  void _onChangeList(ChangeListEvent event, Emitter<AddTaskState> emit) {
    if (state is AddTaskFormState) {
      final currentState = state as AddTaskFormState;
      emit(currentState.copyWith(selectedList: event.list));
    }
  }

  void _onSaveTask(SaveTaskEvent event, Emitter<AddTaskState> emit) async {
    if (state is AddTaskFormState) {
      final formState = state as AddTaskFormState;
      emit(AddTaskLoading());

      try {
        final date = formState.selectedDate ?? DateTime.now();
        final time = formState.selectedTime ?? const TimeOfDay(hour: 0, minute: 0);

        if (event.isEditing && formState.taskId != null) {
          // Cập nhật task hiện có
          final updatedTask = Task(
            id: formState.taskId!,
            title: event.title,
            date: date,
            time: time,
            repeat: formState.selectedRepeat,
            list: formState.selectedList,
            originalList: formState.selectedList,
            isCompleted: false,
          );

          final result = await updateTask(updatedTask);
          result.fold(
            (failure) => emit(AddTaskError(failure.message)),
            (_) => emit(const AddTaskSuccess(isEditing: true)),
          );
        } else {
          // Tạo task mới
          final newTask = Task(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: event.title,
            date: date,
            time: time,
            repeat: formState.selectedRepeat,
            list: formState.selectedList,
            originalList: formState.selectedList,
            isCompleted: false,
          );

          final result = await addTask(newTask);
          result.fold(
            (failure) => emit(AddTaskError(failure.message)),
            (_) => emit(const AddTaskSuccess(isEditing: false)),
          );
        }
      } catch (e) {
        developer.log('Lỗi khi lưu task: $e', name: 'AddTaskBloc');
        emit(AddTaskError('Không thể lưu task: $e'));
      }
    }
  }

  void _onDeleteTask(DeleteTaskEvent event, Emitter<AddTaskState> emit) async {
    if (state is AddTaskFormState) {
      final formState = state as AddTaskFormState;
      
      if (formState.taskId != null) {
        emit(AddTaskLoading());
        
        try {
          final result = await deleteTask(formState.taskId!);
          result.fold(
            (failure) => emit(AddTaskError(failure.message)),
            (_) => emit(const AddTaskSuccess(isEditing: true)),
          );
        } catch (e) {
          developer.log('Lỗi khi xóa task: $e', name: 'AddTaskBloc');
          emit(AddTaskError('Không thể xóa task: $e'));
        }
      }
    }
  }
} 