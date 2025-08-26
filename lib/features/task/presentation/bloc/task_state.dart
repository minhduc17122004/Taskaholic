import 'package:equatable/equatable.dart';
import 'package:taskaholic/features/task/domain/entities/task_entity.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskRefreshing extends TaskState { 
  final List<TaskEntity> tasks;
  final List<TaskEntity> completedTasks;
  final String? currentList;

  const TaskRefreshing({
    required this.tasks,
    required this.completedTasks,
    this.currentList,
  });

  @override
  List<Object?> get props => [tasks, completedTasks, currentList];
}

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

  TasksLoaded copyWith({
    List<TaskEntity>? tasks,
    List<TaskEntity>? completedTasks,
    String? currentList,
  }) {
    return TasksLoaded(
      tasks: tasks ?? this.tasks,
      completedTasks: completedTasks ?? this.completedTasks,
      currentList: currentList ?? this.currentList,
    );
  }

  List<TaskEntity> getTasksByCategory(String categoryName) {
    if (categoryName == 'Danh sách tất cả') {
      return tasks;
    } else {
      return tasks.where((task) => task.category == categoryName).toList();
    }
  }

  int countTasksInCategory(String categoryName) {
    if (categoryName == 'Danh sách tất cả') {
      return tasks.length;
    } else {
      return tasks.where((task) => task.category == categoryName).length;
    }
  }

  Map<String, List<TaskEntity>> getCompletedTasksByCategory() {
    final Map<String, List<TaskEntity>> tasksByCategory = {};
    for (var task in completedTasks) {
      final categoryName = task.category ?? 'Không có danh mục';
      if (!tasksByCategory.containsKey(categoryName)) {
        tasksByCategory[categoryName] = [];
      }
      tasksByCategory[categoryName]!.add(task);
    }
    return tasksByCategory;
  }

  Map<String, List<TaskEntity>> getTasksByCategoryForCategory(String categoryName) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final endOfWeek = today.add(Duration(days: 7 - now.weekday));

    final List<TaskEntity> filteredTasks;
    if (categoryName == 'Danh sách tất cả') {
      filteredTasks = tasks;
    } else {
      filteredTasks = tasks.where((task) => task.category == categoryName).toList();
    }

    final Map<String, List<TaskEntity>> categorizedTasks = {
      'Quá hạn': [],
      'Hôm nay': [],
      'Ngày mai': [],
      'Tuần này': [],
      'Tuần tới': [],
      'Tháng tới': [],
      'Năm tới': [],
      'Không có ngày': [],
    };

    final endOfMonth = DateTime(today.year, today.month + 1, 0);
    final endOfYear = DateTime(today.year, 12, 31);

    for (var task in filteredTasks) {
      // Nếu task không có ngày, thêm vào danh mục "Không có ngày"
      if (task.date == null) {
        categorizedTasks['Không có ngày']!.add(task);
        continue;
      }
      
      final taskDay = DateTime(task.date!.year, task.date!.month, task.date!.day);
      
      if (taskDay.isBefore(today)) {
        categorizedTasks['Quá hạn']!.add(task);
      } else if (taskDay.isAtSameMomentAs(today)) {
        categorizedTasks['Hôm nay']!.add(task);
      } else if (taskDay.isAtSameMomentAs(tomorrow)) {
        categorizedTasks['Ngày mai']!.add(task);
      } else if (taskDay.isBefore(endOfWeek) || taskDay.isAtSameMomentAs(endOfWeek)) {
        categorizedTasks['Tuần này']!.add(task);
      } else if (taskDay.isAfter(endOfWeek) && taskDay.isBefore(endOfWeek.add(const Duration(days: 7))) || taskDay.isAtSameMomentAs(endOfWeek.add(const Duration(days: 7)))) {
        categorizedTasks['Tuần tới']!.add(task);
      } else if (taskDay.isAfter(endOfWeek.add(const Duration(days: 7))) && taskDay.isBefore(endOfMonth) || taskDay.isAtSameMomentAs(endOfMonth)) {
        categorizedTasks['Tháng tới']!.add(task);
      } else if (taskDay.isAfter(endOfMonth) && taskDay.isBefore(endOfYear) || taskDay.isAtSameMomentAs(endOfYear)) {
        categorizedTasks['Năm tới']!.add(task);
      } else {
        // Các task có ngày xa hơn được xác định thời gian cụ thể
        final categoryName = task.getTaskDate();
        if (!categorizedTasks.containsKey(categoryName)) {
          categorizedTasks[categoryName] = [];
        }
        categorizedTasks[categoryName]!.add(task);
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