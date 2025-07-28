import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/add_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_task.dart';
import '../../domain/usecases/update_task.dart';
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
    on<LoadTasks>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<ToggleTaskEvent>(_onToggleTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
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
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      emit(TaskLoading());
      
      try {
        final result = await addTask(event.task);
        
        result.fold(
          (failure) {
            developer.log('Lỗi khi thêm công việc: ${failure.message}', name: 'TaskBloc');
            emit(TaskError(failure.message));
          },
          (_) {
            emit(TaskActionSuccess('Đã thêm công việc thành công'));
            
            // Lên lịch thông báo nếu task có thời gian
            _scheduleNotificationForTask(event.task);
            
            add(const LoadTasks());
          },
        );
      } catch (e) {
        developer.log('Lỗi không xác định khi thêm công việc: $e', name: 'TaskBloc');
        emit(TaskError('Không thể thêm công việc: $e'));
      }
    }
  }

  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      emit(TaskLoading());
      
      try {
        final result = await updateTask(event.task);
        
        result.fold(
          (failure) {
            developer.log('Lỗi khi cập nhật công việc: ${failure.message}', name: 'TaskBloc');
            emit(TaskError(failure.message));
          },
          (_) {
            emit(TaskActionSuccess('Đã cập nhật công việc thành công'));
            
            // Hủy thông báo cũ và lên lịch lại nếu cần
            _notificationService.cancelNotification(int.parse(event.task.id));
            _scheduleNotificationForTask(event.task);
            
            add(const LoadTasks());
          },
        );
      } catch (e) {
        developer.log('Lỗi không xác định khi cập nhật công việc: $e', name: 'TaskBloc');
        emit(TaskError('Không thể cập nhật công việc: $e'));
      }
    }
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      emit(TaskLoading());
      
      try {
        final result = await deleteTask(event.taskId);
        
        result.fold(
          (failure) {
            developer.log('Lỗi khi xóa công việc: ${failure.message}', name: 'TaskBloc');
            emit(TaskError(failure.message));
          },
          (_) {
            emit(TaskActionSuccess('Đã xóa công việc thành công'));
            
            // Hủy thông báo cho task đã xóa
            _notificationService.cancelNotification(int.parse(event.taskId));
            
            add(const LoadTasks());
          },
        );
      } catch (e) {
        developer.log('Lỗi không xác định khi xóa công việc: $e', name: 'TaskBloc');
        emit(TaskError('Không thể xóa công việc: $e'));
      }
    }
  }

  Future<void> _onToggleTask(ToggleTaskEvent event, Emitter<TaskState> emit) async {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;
      
      try {
        final result = await toggleTask(event.taskId);
        
        result.fold(
          (failure) {
            developer.log('Lỗi khi đánh dấu công việc: ${failure.message}', name: 'TaskBloc');
            emit(TaskError(failure.message));
          },
          (_) {
            // Tìm task trong danh sách để biết trạng thái hiện tại
            final allTasks = [...currentState.tasks, ...currentState.completedTasks];
            final task = allTasks.firstWhere(
              (t) => t.id == event.taskId, 
              orElse: () => TaskEntity(
                id: event.taskId,
                title: '',
                date: DateTime.now(),
                time: const TimeOfDay(hour: 0, minute: 0),
                repeat: '',
                list: '',
                originalList: '',
                isCompleted: false,
              ),
            );
            
            // Nếu task đang được đánh dấu là hoàn thành, hủy thông báo
            if (!task.isCompleted) {
              _notificationService.cancelNotification(int.parse(event.taskId));
            } else {
              // Task đang được đánh dấu là chưa hoàn thành, lên lịch lại thông báo
              _scheduleNotificationForTask(task);
            }
            
            add(const LoadTasks());
          },
        );
      } catch (e) {
        developer.log('Lỗi không xác định khi đánh dấu công việc: $e', name: 'TaskBloc');
        emit(TaskError('Không thể đánh dấu công việc: $e'));
      }
    }
  }
  
  // Hàm lên lịch thông báo cho task
  void _scheduleNotificationForTask(TaskEntity task) {
    try {
      // Chỉ lên lịch thông báo nếu task có thời gian và chưa hoàn thành
      if (task.hasTime && !task.isCompleted) {
        final taskTime = DateTime(
          task.date.year,
          task.date.month,
          task.date.day,
          task.time.hour,
          task.time.minute,
        );
        
        // Chỉ lên lịch thông báo nếu thời gian trong tương lai
        if (taskTime.isAfter(DateTime.now())) {
          developer.log('Lên lịch thông báo cho task: ${task.title} vào lúc $taskTime', name: 'TaskBloc');
          
          _notificationService.scheduleTaskNotification(
            id: int.parse(task.id),
            title: 'Nhắc nhở: ${task.title}',
            body: 'Đến hạn: ${task.getFormattedDate()} lúc ${task.time.hour}:${task.time.minute.toString().padLeft(2, '0')}',
            scheduledDate: taskTime,
            payload: task.id,
          );
        } else {
          developer.log('Không lên lịch thông báo cho task đã qua: ${task.title}', name: 'TaskBloc');
        }
      }
    } catch (e) {
      developer.log('Lỗi khi lên lịch thông báo: $e', name: 'TaskBloc', error: e);
    }
  }
} 