// Thẻ hiển thị 1 task
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:taskaholic/core/themes/app_color.dart';
import 'package:taskaholic/features/task/domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onToggle;

  const TaskCard({
    required this.task,
    this.onTap,
    this.onToggle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted 
            ? AppColors.backgroundDark.withValues(alpha: 0.2)
            : AppColors.backgroundDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isCompleted ? 0.7 : 1.0,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.textOnPrimary.withValues(alpha: 0.1),
          highlightColor: AppColors.textOnPrimary.withValues(alpha: 0.05),
          onTap: () {
            // Handle task detail navigation
            if (onTap != null) {
              try {
                onTap!();
              } catch (e) {
                developer.log('Error in task tap: $e', name: 'TaskCard');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: $e'),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Checkbox with separate tap handling
                GestureDetector(
                  onTap: () {
                    // Only handle checkbox toggle, prevent task detail navigation
                    if (onToggle != null) {
                      onToggle!(!isCompleted);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? AppColors.backgroundDark
                            : Colors.transparent,
                        border: Border.all(
                          color: AppColors.backgroundDark,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: AppColors.textOnPrimary,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Task content (tappable for navigation)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task title
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          color: AppColors.textOnPrimary,
                          decorationColor: AppColors.textSecondary,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        child: Text(task.title),
                      ),
                      // Task details
                      if (_hasTaskDetails())
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: _buildTaskDetails(),
                        ),
                    ],
                  ),
                ),
                // Visual indicator that task is tappable
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _hasTaskDetails() {
    return task.hasTime || task.getFormattedDate().isNotEmpty || 
           (task.category != null && task.category!.isNotEmpty);
  }

  Widget _buildTaskDetails() {
    final List<Widget> details = [];
    
    // Date info
    if (task.getFormattedDate().isNotEmpty) {
      details.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            task.getFormattedDate(),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ));
    }
    
    // Add comma separator if both date and time exist
    if (task.hasTime && task.getFormattedDate().isNotEmpty) {
      details.add(const Text(
        ', ',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ));
    }
    
    // Time info
    if (task.hasTime) {
      details.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            task.getFormattedTime(),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ));
    }
    
    // Category info (on new line if date/time exists)
    if (task.category != null && task.category!.isNotEmpty) {
      if (details.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: details),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.label_outline, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  task.category!,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        );
      } else {
        details.add(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.label_outline, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              task.category!,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ));
      }
    }
    
    return Row(children: details);
  }
}
