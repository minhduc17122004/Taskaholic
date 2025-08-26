import 'package:flutter/material.dart';
import 'package:taskaholic/core/themes/app_color.dart';
import 'package:taskaholic/features/home/presentation/widgets/empty_state.dart';

// Shared content widget that can be used in both standalone page and as tab content
class CompletedContent extends StatelessWidget {
  const CompletedContent({super.key});

  void _handleAddTask(BuildContext context) {
    print('Empty state Add Task button pressed from CompletedPage');
    // TODO: Navigate to add task page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thêm nhiệm vụ mới'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      currentList: 'Hoàn thành',
      onAddTask: () => _handleAddTask(context),
    );
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