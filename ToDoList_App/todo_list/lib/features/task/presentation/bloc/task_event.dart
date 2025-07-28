import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  final bool forceRefresh;

  const LoadTasks({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class AddTaskEvent extends TaskEvent {
  final TaskEntity task;

  const AddTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTaskEvent extends TaskEvent {
  final TaskEntity task;

  const UpdateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  const DeleteTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ToggleTaskEvent extends TaskEvent {
  final String taskId;

  const ToggleTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class FilterTasksEvent extends TaskEvent {
  final String listName;

  const FilterTasksEvent(this.listName);

  @override
  List<Object?> get props => [listName];
}

class SearchTasksEvent extends TaskEvent {
  final String query;

  const SearchTasksEvent(this.query);

  @override
  List<Object?> get props => [query];
} 