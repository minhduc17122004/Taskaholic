import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaholic/core/utils/category_constants.dart';
import 'package:taskaholic/features/home/presentation/widgets/empty_state.dart';
import 'package:taskaholic/features/home/presentation/bloc/home_bloc.dart';
import 'package:taskaholic/features/home/presentation/bloc/home_state.dart';
import 'package:taskaholic/features/task/presentation/pages/task_form_page.dart';

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
        return EmptyState(
          currentList: 'Hoàn thành',
          onAddTask: () => _handleAddTask(context, state.selectedCategoryId),
        );
      },
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