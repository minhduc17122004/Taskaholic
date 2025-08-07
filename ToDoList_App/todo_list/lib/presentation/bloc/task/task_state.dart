import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';

abstract class TaskState extends Equatable {
  const TaskState();
  
  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  final List<Task> completedTasks;

  const TasksLoaded({
    required this.tasks,
    required this.completedTasks,
  });

  @override
  List<Object> get props => [tasks, completedTasks];

  TasksLoaded copyWith({
    List<Task>? tasks,
    List<Task>? completedTasks,
  }) {
    return TasksLoaded(
      tasks: tasks ?? this.tasks,
      completedTasks: completedTasks ?? this.completedTasks,
    );
  }

  // Helper methods from original TaskProvider
  List<Task> getTasksByList(String listName) {
    if (listName == 'Danh sách tất cả') {
      return tasks;
    } else {
      return tasks.where((task) => task.list == listName).toList();
    }
  }

  Map<String, List<Task>> getTasksByCategoryForList(String listName) {
    final filteredTasks = getTasksByList(listName);
    final Map<String, List<Task>> categorized = {};
    
    final categories = [
      'Không có ngày',
      'Quá hạn',
      'Hôm nay',
      'Ngày mai',
      'Tuần này',
      'Sắp tới',
    ];
    
    for (var category in categories) {
      categorized[category] = [];
    }

    for (var task in filteredTasks) {
      final category = task.category;
      if (!categorized.containsKey(category)) {
        categorized[category] = [];
      }
      categorized[category]!.add(task);
    }

    categorized.removeWhere((key, value) => value.isEmpty);
    return categorized;
  }
  
  // Nhóm các công việc đã hoàn thành theo danh mục gốc
  Map<String, List<Task>> getCompletedTasksByList() {
    final Map<String, List<Task>> tasksByList = {};
    
    for (var task in completedTasks) {
      final listName = task.list;
      if (!tasksByList.containsKey(listName)) {
        tasksByList[listName] = [];
      }
      tasksByList[listName]!.add(task);
    }
    
    return tasksByList;
  }

  int countTasksInList(String listName) {
    if (listName == 'Danh sách tất cả') {
      return tasks.length;
    } else {
      return tasks.where((task) => task.list == listName).length;
    }
  }
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object> get props => [message];
}

class TaskActionSuccess extends TaskState {
  final String message;

  const TaskActionSuccess(this.message);

  @override
  List<Object> get props => [message];
} 