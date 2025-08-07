import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/notification_service.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/usecases/add_task.dart';
import '../../../domain/usecases/delete_task.dart';
import '../../../domain/usecases/get_tasks.dart';
import '../../../domain/usecases/toggle_task.dart';
import '../../../domain/usecases/update_task.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  final AddTask addTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;
  final ToggleTask toggleTask;
  final NotificationService _notificationService = NotificationService();
  
  // Biến để kiểm soát debounce
  Timer? _debounceTimer;
  bool _isLoadingTasks = false;

  TaskBloc({
    required this.getTasks,
    required this.addTask,
    required this.updateTask,
    required this.deleteTask,
    required this.toggleTask,
  }) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<ToggleTaskEvent>(_onToggleTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    // Nếu đã có dữ liệu và không yêu cầu tải lại, sử dụng dữ liệu hiện tại
    if (state is TasksLoaded && !event.forceRefresh) {
      developer.log('Sử dụng dữ liệu đã tải sẵn', name: 'TaskBloc');
      return;
    }
    
    // Nếu đang tải dữ liệu, bỏ qua yêu cầu mới
    if (_isLoadingTasks) {
      developer.log('Đang tải dữ liệu, bỏ qua yêu cầu mới', name: 'TaskBloc');
      return;
    }
    
    // Đánh dấu đang tải
    _isLoadingTasks = true;
    
    // Hiển thị trạng thái loading ngay lập tức
    developer.log('Đang tải danh sách công việc', name: 'TaskBloc');
    emit(TaskLoading());
    
    // Hủy timer debounce cũ nếu có
    _debounceTimer?.cancel();
    
    try {
      final result = await getTasks();
      if (emit.isDone) return; // Kiểm tra nếu emit đã hoàn thành
      
      await result.fold(
        (failure) async {
          developer.log('Lỗi khi tải danh sách công việc: ${failure.message}', name: 'TaskBloc');
          if (!emit.isDone) emit(TaskError(failure.message));
        },
        (data) async {
          developer.log('Đã tải ${data.tasks.length} công việc và ${data.completedTasks.length} công việc đã hoàn thành', name: 'TaskBloc');
          if (!emit.isDone) emit(TasksLoaded(tasks: data.tasks, completedTasks: data.completedTasks));
        },
      );
    } finally {
      // Đánh dấu đã tải xong
      _isLoadingTasks = false;
    }
  }

  Future<void> _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    developer.log('🚀 Bắt đầu thêm công việc: ${event.task.title}', name: 'TaskBloc');
    final result = await addTask(event.task);
    
    if (emit.isDone) return;
    
    await result.fold(
      (failure) async {
        developer.log('❌ Lỗi khi thêm công việc: ${failure.message}', name: 'TaskBloc');
        if (!emit.isDone) emit(TaskError(failure.message));
      },
      (_) async {
        developer.log('✅ Đã thêm công việc thành công', name: 'TaskBloc');
        
        // Emit success state first
        if (!emit.isDone) emit(const TaskActionSuccess('Đã thêm công việc thành công'));
        
        // Lên lịch thông báo nếu task có thời gian
        _scheduleNotificationForTask(event.task);
        
        // Add small delay to ensure Firebase write completion
        developer.log('⏳ Đợi Firebase hoàn tất...', name: 'TaskBloc');
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Then reload tasks
        developer.log('🔄 Tải lại danh sách công việc...', name: 'TaskBloc');
        if (!emit.isDone) add(const LoadTasks(forceRefresh: true));
      },
    );
  }

  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    developer.log('Đang cập nhật công việc: ${event.task.title}', name: 'TaskBloc');
    final result = await updateTask(event.task);
    
    if (emit.isDone) return;
    
    await result.fold(
      (failure) async {
        developer.log('Lỗi khi cập nhật công việc: ${failure.message}', name: 'TaskBloc');
        if (!emit.isDone) emit(TaskError(failure.message));
      },
      (_) async {
        developer.log('Đã cập nhật công việc thành công', name: 'TaskBloc');
        
        // Emit success state first
        if (!emit.isDone) emit(const TaskActionSuccess('Đã cập nhật công việc thành công'));
        
        // Hủy thông báo cũ và lên lịch lại nếu cần
        await _notificationService.cancelNotification(int.parse(event.task.id));
        _scheduleNotificationForTask(event.task);
        
        // Then reload tasks
        if (!emit.isDone) add(const LoadTasks(forceRefresh: true));
      },
    );
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    developer.log('Đang xóa công việc có ID: ${event.taskId}', name: 'TaskBloc');
    final result = await deleteTask(event.taskId);
    
    if (emit.isDone) return;
    
    await result.fold(
      (failure) async {
        developer.log('Lỗi khi xóa công việc: ${failure.message}', name: 'TaskBloc');
        if (!emit.isDone) emit(TaskError(failure.message));
      },
      (_) async {
        developer.log('Đã xóa công việc thành công', name: 'TaskBloc');
        
        // Emit success state first
        if (!emit.isDone) emit(const TaskActionSuccess('Đã xóa công việc thành công'));
        
        // Hủy thông báo cho task đã xóa
        await _notificationService.cancelNotification(int.parse(event.taskId));
        
        // Then reload tasks
        if (!emit.isDone) add(const LoadTasks(forceRefresh: true));
      },
    );
  }

  Future<void> _onToggleTask(ToggleTaskEvent event, Emitter<TaskState> emit) async {
    developer.log('🔄 Đang chuyển trạng thái công việc: ${event.taskId}', name: 'TaskBloc');
    final result = await toggleTask(event.taskId);
    
    if (emit.isDone) return;
    
    await result.fold(
      (failure) async {
        developer.log('❌ Lỗi khi chuyển trạng thái công việc: ${failure.message}', name: 'TaskBloc');
        if (!emit.isDone) emit(TaskError(failure.message));
      },
      (_) async {
        developer.log('✅ Đã chuyển trạng thái công việc thành công', name: 'TaskBloc');
        
        // Emit success state for immediate feedback
        if (!emit.isDone) emit(const TaskActionSuccess('Đã cập nhật trạng thái công việc'));
        
        // Handle notifications based on task completion status
        if (state is TasksLoaded) {
          final currentState = state as TasksLoaded;
          final task = currentState.tasks.firstWhere(
            (t) => t.id == event.taskId, 
            orElse: () => currentState.completedTasks.firstWhere(
              (t) => t.id == event.taskId,
              orElse: () => Task(
                id: event.taskId,
                title: '',
                date: DateTime.now(),
                time: const TimeOfDay(hour: 0, minute: 0),
                repeat: '',
                list: '',
                originalList: '',
                isCompleted: false,
              ),
            ),
          );
          
          if (!task.isCompleted) {
            // Task is being marked as completed - cancel notification
            developer.log('🔕 Hủy thông báo cho task đã hoàn thành', name: 'TaskBloc');
            await _notificationService.cancelNotification(int.parse(event.taskId));
          } else {
            // Task is being unmarked - reschedule notification
            developer.log('🔔 Lên lịch lại thông báo cho task chưa hoàn thành', name: 'TaskBloc');
            _scheduleNotificationForTask(task);
          }
        }
        
        // Add slight delay for better UX, then reload
        await Future.delayed(const Duration(milliseconds: 200));
        developer.log('🔄 Tải lại danh sách sau khi toggle...', name: 'TaskBloc');
        if (!emit.isDone) add(const LoadTasks(forceRefresh: true));
      },
    );
  }
  
  // Hàm lên lịch thông báo cho task
  void _scheduleNotificationForTask(Task task) {
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