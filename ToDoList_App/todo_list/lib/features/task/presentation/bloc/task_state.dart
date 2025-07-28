import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<TaskEntity> tasks;
  final List<TaskEntity> completedTasks;
  final String? currentList;

  const TasksLoaded({
    required this.tasks,
    required this.completedTasks,
    this.currentList,
  });

  @override
  List<Object?> get props => [tasks, completedTasks, currentList];

  List<TaskEntity> getTasksByList(String listName) {
    if (listName == 'Danh sách tất cả') {
      return tasks;
    } else {
      return tasks.where((task) => task.list == listName).toList();
    }
  }

  int countTasksInList(String listName) {
    if (listName == 'Danh sách tất cả') {
      return tasks.length;
    } else {
      return tasks.where((task) => task.list == listName).length;
    }
  }

  Map<String, List<TaskEntity>> getCompletedTasksByList() {
    final Map<String, List<TaskEntity>> tasksByList = {};
    for (var task in completedTasks) {
      final listName = task.list;
      if (!tasksByList.containsKey(listName)) {
        tasksByList[listName] = [];
      }
      tasksByList[listName]!.add(task);
    }
    return tasksByList;
  }

  Map<String, List<TaskEntity>> getTasksByCategoryForList(String listName) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final endOfWeek = today.add(Duration(days: 7 - now.weekday));

    final List<TaskEntity> filteredTasks;
    if (listName == 'Danh sách tất cả') {
      filteredTasks = tasks;
    } else {
      filteredTasks = tasks.where((task) => task.list == listName).toList();
    }

    final Map<String, List<TaskEntity>> categorizedTasks = {
      'Quá hạn': [],
      'Hôm nay': [],
      'Ngày mai': [],
      'Tuần này': [],
      'Không có ngày': [],
    };

    for (var task in filteredTasks) {
      final taskDay = DateTime(task.date.year, task.date.month, task.date.day);
      
      if (task.list == 'Mặc định') {
        categorizedTasks['Không có ngày']!.add(task);
      } else if (taskDay.isBefore(today)) {
        categorizedTasks['Quá hạn']!.add(task);
      } else if (taskDay.isAtSameMomentAs(today)) {
        categorizedTasks['Hôm nay']!.add(task);
      } else if (taskDay.isAtSameMomentAs(tomorrow)) {
        categorizedTasks['Ngày mai']!.add(task);
      } else if (taskDay.isBefore(endOfWeek) || taskDay.isAtSameMomentAs(endOfWeek)) {
        categorizedTasks['Tuần này']!.add(task);
      } else {
        // Các task có ngày xa hơn được nhóm theo danh mục
        final listName = task.list;
        if (!categorizedTasks.containsKey(listName)) {
          categorizedTasks[listName] = [];
        }
        categorizedTasks[listName]!.add(task);
      }
    }

    // Loại bỏ các danh mục trống
    categorizedTasks.removeWhere((key, value) => value.isEmpty);

    return categorizedTasks;
  }
}

class TaskActionSuccess extends TaskState {
  final String message;

  const TaskActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
} 