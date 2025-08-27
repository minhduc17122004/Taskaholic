import 'package:equatable/equatable.dart';
import '../../../task/domain/entities/task_entity.dart';
import '../../../../core/utils/category_constants.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  final int currentIndex;
  final String selectedCategoryId;

  const HomeInitial({
    this.currentIndex = 0,
    this.selectedCategoryId = 'all', // Default to 'Tất cả'
  });

  HomeInitial copyWith({
    int? currentIndex,
    String? selectedCategoryId,
  }) {
    return HomeInitial(
      currentIndex: currentIndex ?? this.currentIndex,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }

  @override
  List<Object> get props => [currentIndex, selectedCategoryId];
}

class HomeLoading extends HomeState {
  final int currentIndex;
  final String selectedCategoryId;

  const HomeLoading({
    required this.currentIndex,
    required this.selectedCategoryId,
  });

  @override
  List<Object> get props => [currentIndex, selectedCategoryId];
}

class HomeLoaded extends HomeState {
  final int currentIndex;
  final String selectedCategoryId;
  final List<TaskEntity> tasks;
  final List<TaskEntity> completedTasks;

  const HomeLoaded({
    required this.currentIndex,
    required this.selectedCategoryId,
    required this.tasks,
    required this.completedTasks,
  });

  HomeLoaded copyWith({
    int? currentIndex,
    String? selectedCategoryId,
    List<TaskEntity>? tasks,
    List<TaskEntity>? completedTasks,
  }) {
    return HomeLoaded(
      currentIndex: currentIndex ?? this.currentIndex,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      tasks: tasks ?? this.tasks,
      completedTasks: completedTasks ?? this.completedTasks,
    );
  }

  // Helper methods from original TasksLoaded state
  List<TaskEntity> getTasksByCategory(String categoryId) {
    if (categoryId == 'all') {
      return tasks;
    } else {
      // Get the category name from ID for comparison  
      final categoryData = CategoryConstants.getCategoryById(categoryId);
      final categoryName = categoryData?.name;
      
      if (categoryName == null) return [];
      
      return tasks.where((task) => task.category == categoryName).toList();
    }
  }

  int countTasksInCategory(String categoryId) {
    if (categoryId == 'all') {
      return tasks.length;
    } else {
      // Get the category name from ID for comparison
      final categoryData = CategoryConstants.getCategoryById(categoryId);
      final categoryName = categoryData?.name;
      
      if (categoryName == null) return 0;
      
      return tasks.where((task) => task.category == categoryName).length;
    }
  }

  Map<String, List<TaskEntity>> getTasksByCategoryForCategory(String categoryId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final endOfWeek = today.add(Duration(days: 7 - now.weekday));

    final List<TaskEntity> filteredTasks;
    if (categoryId == 'all') {
      filteredTasks = tasks;
    } else {
      // Get the category name from ID for comparison
      final categoryData = CategoryConstants.getCategoryById(categoryId);
      final categoryName = categoryData?.name;
      
      if (categoryName == null) {
        filteredTasks = [];
      } else {
        filteredTasks = tasks.where((task) => task.category == categoryName).toList();
      }
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

  @override
  List<Object> get props => [currentIndex, selectedCategoryId, tasks, completedTasks];
}

class HomeError extends HomeState {
  final int currentIndex;
  final String selectedCategoryId;
  final String message;

  const HomeError({
    required this.currentIndex,
    required this.selectedCategoryId,
    required this.message,
  });

  @override
  List<Object> get props => [currentIndex, selectedCategoryId, message];
}
