import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaholic/core/services/notification_service.dart';
import 'package:taskaholic/core/usecases/usecase.dart';
import 'package:taskaholic/features/task/domain/entities/task_entity.dart';
import 'package:taskaholic/features/task/domain/usecases/add_task.dart';
import 'package:taskaholic/features/task/domain/usecases/delete_task.dart';
import 'package:taskaholic/features/task/domain/usecases/get_tasks.dart';
import 'package:taskaholic/features/task/domain/usecases/toggle_task.dart';
import 'package:taskaholic/features/task/domain/usecases/update_task.dart';

import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  final AddTask addTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;
  final ToggleTask toggleTask;
  final NotificationService _notificationService;

  TaskBloc({
    required this.getTasks,
    required this.addTask,
    required this.updateTask,
    required this.deleteTask,
    required this.toggleTask,
    required NotificationService notificationService,
  }) : _notificationService = notificationService,
       super(TaskInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<ToggleTaskEvent>(_onToggleTask);
  }

  Future<void> _onLoadTasks(LoadTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    
    try {
      final result = await getTasks(NoParams());
      
      result.fold(
        (failure) {
          developer.log('Lỗi khi tải danh sách công việc: ${failure.message}', name: 'TaskBloc');
          emit(TaskError(failure.message));
        },
        (tasks) {
          final pendingTasks = tasks.where((task) => !task.isCompleted).toList();
          final completedTasks = tasks.where((task) => task.isCompleted).toList();
          
          emit(TasksLoaded(
            tasks: pendingTasks,
            completedTasks: completedTasks,
          ));
        },
      );
    } catch (e) {
      developer.log('Lỗi không xác định khi tải danh sách công việc: $e', name: 'TaskBloc');
      emit(TaskError('Không thể tải danh sách công việc: $e'));
    }
  }

  Future<void> _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    // Store current state info if available
    List<TaskEntity> currentTasks = [];
    List<TaskEntity> currentCompletedTasks = [];
    String? currentList;
    
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      currentTasks = currentState.tasks;
      currentCompletedTasks = currentState.completedTasks;
      currentList = currentState.currentList;
      
      // Show refreshing state if we have data
      emit(TaskRefreshing(
        tasks: currentTasks,
        completedTasks: currentCompletedTasks,
        currentList: currentList,
      ));
    } else {
      // Show loading for initial state
      emit(TaskLoading());
    }
    
    try {
      final result = await addTask(event.task);
      
      result.fold(
        (failure) {
          developer.log('Lỗi khi thêm công việc: ${failure.message}', name: 'TaskBloc');
          if (state is TaskRefreshing) {
            // Khôi phục state trước đó khi có lỗi
            emit(TasksLoaded(
              tasks: currentTasks,
              completedTasks: currentCompletedTasks,
              currentList: currentList,
            ));
          }
          emit(TaskError(failure.message));
        },
        (_) {
          emit(TaskActionSuccess('Đã thêm công việc thành công'));
          
          // Lên lịch thông báo nếu task có thời gian
          _scheduleNotificationForTask(event.task);
          
          // Reload tasks to get fresh data
          add(const LoadTasksEvent());
        },
      );
    } catch (e) {
      developer.log('Lỗi không xác định khi thêm công việc: $e', name: 'TaskBloc');
      if (state is TaskRefreshing) {
        // Khôi phục state trước đó khi có lỗi
        emit(TasksLoaded(
          tasks: currentTasks,
          completedTasks: currentCompletedTasks,
          currentList: currentList,
        ));
      }
      emit(TaskError('Không thể thêm công việc: $e'));
    }
  }

  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      
      // Hiển thị trạng thái refreshing mà không mất dữ liệu hiện tại
      emit(TaskRefreshing(
        tasks: currentState.tasks,
        completedTasks: currentState.completedTasks,
        currentList: currentState.currentList,
      ));
      
      try {
        final result = await updateTask(event.task);
        
        result.fold(
          (failure) {
            developer.log('Lỗi khi cập nhật công việc: ${failure.message}', name: 'TaskBloc');
            // Khôi phục state trước đó khi có lỗi
            emit(currentState);
            emit(TaskError(failure.message));
          },
          (_) async {
            emit(TaskActionSuccess('Đã cập nhật công việc thành công'));
            
            // Hủy thông báo cũ và lên lịch lại nếu cần
            await _notificationService.cancelTaskNotification(event.task.id);
            _scheduleNotificationForTask(event.task);
            
            add(const LoadTasksEvent());
          },
        );
      } catch (e) {
        developer.log('Lỗi không xác định khi cập nhật công việc: $e', name: 'TaskBloc');
        // Khôi phục state trước đó khi có lỗi
        emit(currentState);
        emit(TaskError('Không thể cập nhật công việc: $e'));
      }
    }
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      
      // Hiển thị trạng thái refreshing mà không mất dữ liệu hiện tại
      emit(TaskRefreshing(
        tasks: currentState.tasks,
        completedTasks: currentState.completedTasks,
        currentList: currentState.currentList,
      ));
      
      try {
        final result = await deleteTask(event.taskId);
        
        result.fold(
          (failure) {
            developer.log('Lỗi khi xóa công việc: ${failure.message}', name: 'TaskBloc');
            // Khôi phục state trước đó khi có lỗi
            emit(currentState);
            emit(TaskError(failure.message));
          },
          (_) async {
            emit(TaskActionSuccess('Đã xóa công việc thành công'));
            
            // Hủy thông báo cho task đã xóa
            await _notificationService.cancelTaskNotification(event.taskId);
            
            add(const LoadTasksEvent());
          },
        );
      } catch (e) {
        developer.log('Lỗi không xác định khi xóa công việc: $e', name: 'TaskBloc');
        // Khôi phục state trước đó khi có lỗi
        emit(currentState);
        emit(TaskError('Không thể xóa công việc: $e'));
      }
    }
  }

  Future<void> _onToggleTask(ToggleTaskEvent event, Emitter<TaskState> emit) async {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      
      // Tìm task cần toggle
      final allTasks = [...currentState.tasks, ...currentState.completedTasks];
      final taskIndex = allTasks.indexWhere((task) => task.id == event.taskId);
      
      // Kiểm tra task có tồn tại trong local state không
      if (taskIndex == -1) {
        developer.log(
          'Task với ID ${event.taskId} không tìm thấy trong local state', 
          name: 'TaskBloc',
          level: 900, // WARNING level
        );
        emit(TaskError('Không tìm thấy công việc cần cập nhật'));
        return;
      }
      
      final task = allTasks[taskIndex];
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
      );
      
      // Instant UI update - di chuyển task giữa danh sách
      List<TaskEntity> newTasks = List.from(currentState.tasks);
      List<TaskEntity> newCompletedTasks = List.from(currentState.completedTasks);
      
      if (task.isCompleted) {
        // Task đang completed → chuyển về pending
        newCompletedTasks.removeWhere((t) => t.id == event.taskId);
        newTasks.add(updatedTask);
      } else {
        // Task đang pending → chuyển về completed
        newTasks.removeWhere((t) => t.id == event.taskId);
        newCompletedTasks.add(updatedTask);
      }
      
      // Emit state mới ngay lập tức (optimistic update)
      emit(currentState.copyWith(
        tasks: newTasks,
        completedTasks: newCompletedTasks,
      ));
      
      try {
        final result = await toggleTask(event.taskId);
        
        result.fold(
          (failure) {
            developer.log(
              'API lỗi khi toggle task ${event.taskId}: ${failure.message}', 
              name: 'TaskBloc'
            );
            // Khôi phục state trước đó khi có lỗi
            emit(currentState);
            emit(TaskError(failure.message));
          },
          (_) {
            developer.log('Toggle task ${event.taskId} thành công', name: 'TaskBloc');
            // Reload từ database để đảm bảo tính nhất quán
            add(const LoadTasksEvent());
          },
        );
      } catch (e) {
        developer.log(
          'Exception khi toggle task ${event.taskId}: $e', 
          name: 'TaskBloc', 
          error: e
        );
        // Khôi phục state trước đó khi có lỗi
        emit(currentState);
        emit(TaskError('Không thể đánh dấu công việc: $e'));
      }
    }
  }

  /// Schedule notification for a task if it has valid date/time
  void _scheduleNotificationForTask(TaskEntity task) {
    try {
      // Sử dụng extension methods từ NotificationService
      if (!task.canHaveNotification) {
        developer.log(
          'Không lên lịch thông báo cho task: ${task.title} - '
          'lý do: ${task.isCompleted ? "đã hoàn thành" : "thiếu ngày/giờ"}',
          name: 'TaskBloc',
        );
        return;
      }

      final notificationDateTime = task.notificationDateTime!;
      
      // Schedule notification asynchronously 
      _notificationService.scheduleTaskNotification(
        taskId: task.id,
        title: task.notificationTitle,
        body: task.notificationBody,
        scheduledDate: notificationDateTime,
      ).catchError((error) {
        developer.log(
          'Lỗi khi lên lịch thông báo cho task ${task.title}: $error',
          name: 'TaskBloc',
          error: error,
        );
      });
    } catch (e) {
      developer.log(
        'Exception khi lên lịch thông báo cho task ${task.title}: $e',
        name: 'TaskBloc',
        error: e,
      );
    }
  }
} 