import 'package:flutter/material.dart';
import 'package:taskaholic/core/themes/app_color.dart';
import 'package:taskaholic/core/utils/task_date_utils.dart';
import 'package:taskaholic/features/task/domain/entities/task_entity.dart';
import 'task_card.dart';

class TaskGroupView extends StatelessWidget {
  final Map<String, List<TaskEntity>> tasksByCategory;
  final String currentList;
  final int totalTasks;
  final Widget addTaskCard;
  final Function(String, List<TaskEntity>, Color) buildCategorySection;

  const TaskGroupView({
    super.key,
    required this.tasksByCategory,
    required this.currentList,
    required this.totalTasks,
    required this.addTaskCard,
    required this.buildCategorySection,
  });

  String _getFormattedDate() {
    return TaskDateUtils.getFormattedDate();
  }

  @override
  Widget build(BuildContext context) {
    // Tạo danh sách các nhóm công việc theo danh mục
    final List<Widget> categoryWidgets = [];
    
    // Thêm danh mục "Quá hạn" nếu có
    if (tasksByCategory.containsKey('Quá hạn')) {
      categoryWidgets.add(
        buildCategorySection(
          'Quá hạn',
          tasksByCategory['Quá hạn']!,
          AppColors.overdue,
        ),
      );
    }
    
    // Thêm danh mục "Hôm nay" nếu có
    if (tasksByCategory.containsKey('Hôm nay')) {
      categoryWidgets.add(
        buildCategorySection(
          'Hôm nay',
          tasksByCategory['Hôm nay']!,
          AppColors.today,
        ),
      );
    }
    
    // Thêm danh mục "Ngày mai" nếu có
    if (tasksByCategory.containsKey('Ngày mai')) {
      categoryWidgets.add(
        buildCategorySection(
          'Ngày mai',
          tasksByCategory['Ngày mai']!,
          AppColors.upcoming,
        ),
      );
    }
    
    // Thêm danh mục "Tuần này" nếu có
    if (tasksByCategory.containsKey('Tuần này')) {
      categoryWidgets.add(
        buildCategorySection(
          'Tuần này',
          tasksByCategory['Tuần này']!,
          AppColors.upcoming,
        ),
      );
    }
    
    // Thêm danh mục "Không có ngày" nếu có
    if (tasksByCategory.containsKey('Không có ngày')) {
      categoryWidgets.add(
        buildCategorySection(
          'Không có ngày',
          tasksByCategory['Không có ngày']!,
          AppColors.upcoming,
        ),
      );
    }
    
    // Các danh mục khác
    for (final category in tasksByCategory.keys) {
      if (!['Quá hạn', 'Hôm nay', 'Ngày mai', 'Tuần này', 'Không có ngày'].contains(category)) {
        categoryWidgets.add(
          buildCategorySection(
            category,
            tasksByCategory[category]!,
            Colors.greenAccent,
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundDark.withValues(alpha: 0.9),
            AppColors.backgroundDark,
          ],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // Header với ngày và thông tin
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getFormattedDate(),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$currentList ($totalTasks)',
                  style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Add Task Card
          addTaskCard,
          
          // Danh sách các danh mục công việc
          ...categoryWidgets,
        ],
      ),
    );
  }
}

class TaskCategorySection extends StatelessWidget {
  final String categoryName;
  final List<TaskEntity> tasks;
  final Color accentColor;
  final Function(TaskEntity)? onTaskTap;
  final Function(TaskEntity, bool?)? onTaskToggle;

  const TaskCategorySection({
    super.key,
    required this.categoryName,
    required this.tasks,
    required this.accentColor,
    this.onTaskTap,
    this.onTaskToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  categoryName,
                  style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tasks List
          ...tasks.map((task) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TaskCard(
              task: task,
              onTap: () => onTaskTap?.call(task),
              onToggle: (value) => onTaskToggle?.call(task, value),
            ),
          )),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}