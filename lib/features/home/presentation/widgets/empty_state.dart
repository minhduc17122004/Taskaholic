import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:taskaholic/core/themes/app_color.dart';

class EmptyState extends StatelessWidget {
  final String currentList;
  final VoidCallback onAddTask;

  const EmptyState({
    super.key,
    required this.currentList,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundDark,
            AppColors.inputBackgroundDark2,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: AppColors.background,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Không có công việc nào',
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy bắt đầu bằng việc thêm nhiệm vụ đầu tiên!',
              style: TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Add Task Button in empty state
            ElevatedButton.icon(
              onPressed: () {
                developer.log('Empty state Add Task button pressed', name: 'HomePage');
                onAddTask();
              },
              icon: const Icon(Icons.add, color: AppColors.textOnPrimary),
              label: const Text(
                'Thêm nhiệm vụ mới',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
