import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaholic/core/themes/app_color.dart';
import 'package:taskaholic/core/utils/category_constants.dart';
import 'package:taskaholic/features/home/presentation/widgets/empty_state.dart';
import 'package:taskaholic/features/home/presentation/widgets/task_group.dart';
import 'package:taskaholic/features/home/presentation/bloc/home_bloc.dart';
import 'package:taskaholic/features/home/presentation/bloc/home_state.dart';
import 'package:taskaholic/features/home/presentation/bloc/home_event.dart';
import 'package:taskaholic/features/task/presentation/pages/task_form_page.dart';
import 'package:taskaholic/features/task/domain/entities/task_entity.dart';

// Shared content widget that can be used in both standalone page and as tab content
class CompletedContent extends StatelessWidget {
  const CompletedContent({super.key});

  void _handleAddTask(BuildContext context, String selectedCategoryId) {
    // Convert category ID to real category name, or null if 'all'
    String? initialCategory;
    if (selectedCategoryId != 'all') {
      final categoryData = CategoryConstants.getCategoryById(selectedCategoryId);
      initialCategory = categoryData?.name;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormPage(
          initialCategory: initialCategory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        if (state is HomeError) {
          final errorState = state;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${errorState.message}',
                  style: const TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<HomeBloc>().add(const LoadTasksEvent()),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (state is HomeLoaded) {
          final loadedState = state;
          final selectedCategoryId = loadedState.selectedCategoryId;
          
          // Get completed tasks for the selected category
          final completedTasks = _getCompletedTasksByCategory(loadedState.completedTasks, selectedCategoryId);
          
          if (completedTasks.isEmpty) {
            return EmptyState(
              currentList: selectedCategoryId == 'all' ? 'Hoàn thành - Tất cả' : 'Hoàn thành - ${CategoryConstants.getCategoryById(selectedCategoryId)?.name ?? selectedCategoryId}',
              onAddTask: () => _handleAddTask(context, selectedCategoryId),
            );
          }

          // Group completed tasks by category
          final tasksByCategory = _groupCompletedTasksByCategory(completedTasks);
          final currentListName = selectedCategoryId == 'all' ? 'Hoàn thành - Tất cả' : 'Hoàn thành - ${CategoryConstants.getCategoryById(selectedCategoryId)?.name}';

          return TaskGroupView(
            tasksByCategory: tasksByCategory,
            currentList: currentListName,
            totalTasks: completedTasks.length,
            addTaskCard: _buildAddTaskCard(context, selectedCategoryId),
            buildCategorySection: (categoryName, tasks, color) {
              return TaskCategorySection(
                categoryName: categoryName,
                tasks: tasks,
                accentColor: color,
                onTaskTap: (task) => _handleTaskTap(context, task),
                onTaskToggle: (task, value) => _handleTaskToggle(context, task),
              );
            },
          );
        }

        // Default state (HomeInitial)
        return EmptyState(
          currentList: 'Hoàn thành - Tất cả',
          onAddTask: () => _handleAddTask(context, 'all'),
        );
      },
    );
  }

  List<TaskEntity> _getCompletedTasksByCategory(List<TaskEntity> allCompletedTasks, String categoryId) {
    if (categoryId == 'all') {
      return allCompletedTasks;
    } else {
      final categoryData = CategoryConstants.getCategoryById(categoryId);
      final categoryName = categoryData?.name;
      
      if (categoryName == null) return [];
      
      return allCompletedTasks.where((task) => task.category == categoryName).toList();
    }
  }

  Map<String, List<TaskEntity>> _groupCompletedTasksByCategory(List<TaskEntity> completedTasks) {
    // Group by actual category, not by date
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

  Widget _buildAddTaskCard(BuildContext context, String selectedCategoryId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.add,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: const Text(
          'Thêm nhiệm vụ mới',
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Tạo nhiệm vụ trong ${selectedCategoryId == 'all' ? 'bất kỳ danh mục nào bạn muốn' : CategoryConstants.getCategoryById(selectedCategoryId)?.name ?? selectedCategoryId}',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondary,
          size: 16,
        ),
        onTap: () => _handleAddTask(context, selectedCategoryId),
      ),
    );
  }

  void _handleTaskTap(BuildContext context, TaskEntity task) {
    // TODO: Navigate to task detail or edit page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormPage(
          // TODO: Add editing support
          initialCategory: task.category,
        ),
      ),
    ).then((_) {
      context.read<HomeBloc>().add(const RefreshTasksEvent());
    });
  }

  void _handleTaskToggle(BuildContext context, TaskEntity task) {
    // TODO: Implement task toggle through TaskBloc
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          task.isCompleted ? 'Đã hủy hoàn thành: ${task.title}' : 'Đã hoàn thành: ${task.title}',
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Refresh tasks to show updated state
    context.read<HomeBloc>().add(const RefreshTasksEvent());
  }
}

// Standalone page that shares AppBar with HomePage
class CompletedPage extends StatelessWidget {
  const CompletedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CompletedContent();
  }
}