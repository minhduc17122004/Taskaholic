import 'package:equatable/equatable.dart';
import '../../../features/task/domain/entities/task_entity.dart' as entity;
import '../../../domain/entities/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {
  final bool forceRefresh;
  
  const LoadTasks({this.forceRefresh = false});
}

class AddTaskEvent extends TaskEvent {
  final Task task;

  const AddTaskEvent(this.task);

  @override
  List<Object> get props => [task];
}

class UpdateTaskEvent extends TaskEvent {
  final Task task;

  const UpdateTaskEvent(this.task);

  @override
  List<Object> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  const DeleteTaskEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class ToggleTaskEvent extends TaskEvent {
  final String taskId;

  const ToggleTaskEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
} 