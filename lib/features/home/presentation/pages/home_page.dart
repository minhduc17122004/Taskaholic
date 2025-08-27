import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaholic/core/themes/app_color.dart';
import 'package:taskaholic/core/utils/category_constants.dart';
import 'package:taskaholic/features/home/presentation/widgets/app_bar.dart';
import 'package:taskaholic/features/home/presentation/widgets/category_title_dropdown.dart';
import 'package:taskaholic/features/home/presentation/widgets/empty_state.dart';
import 'package:taskaholic/features/home/presentation/bloc/home_bloc.dart';
import 'package:taskaholic/features/home/presentation/bloc/home_event.dart';
import 'package:taskaholic/features/home/presentation/bloc/home_state.dart';
import 'package:taskaholic/features/home/presentation/pages/completed_page.dart';
import 'package:taskaholic/features/category/presentation/pages/category_page.dart';
import 'package:taskaholic/features/category/presentation/widgets/add_category_dialog.dart';
import 'package:taskaholic/features/task/presentation/pages/task_form_page.dart';
import 'package:taskaholic/shared/widgets/default_bottom_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  static const List<String> _titles = [
    'Trang chủ',
    'Hoàn thành',
    'Danh mục',
    'Cài đặt',
  ];

  Widget _getPageAtIndex(int index) {
    switch (index) {
      case 0:
        return const _HomeTab();
      case 1:
        return const CompletedContent();
      case 2:
        return const CategoryContent();
      case 3:
        return const _SettingsTab();
      default:
        return const _HomeTab();
    }
  }

  Widget _getLeadingIcon(int index) {
    switch (index) {
      case 0:
        return const Icon(Icons.home, color: AppColors.textOnPrimary, size: 28);
      case 1:
        return const Icon(Icons.check_circle, color: AppColors.textOnPrimary, size: 28);
      case 2:
        return const Icon(Icons.category, color: AppColors.textOnPrimary, size: 28);
      case 3:
        return const Icon(Icons.settings, color: AppColors.textOnPrimary, size: 28);
      default:
        return const Icon(Icons.home, color: AppColors.textOnPrimary, size: 28);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(
            title: (state.currentIndex == 0 || state.currentIndex == 1) ? null : _titles[state.currentIndex],
            titleWidget: (state.currentIndex == 0 || state.currentIndex == 1) 
                ? CategoryTitleDropdown(
                    selectedCategoryId: state.selectedCategoryId,
                    onCategoryChanged: (categoryId, categoryName) {
                      context.read<HomeBloc>().add(ChangeCategoryEvent(categoryId));
                    },
                    showTaskCount: true,
                    taskCount: 12, // TODO: Get actual task count from state
                  )
                : null,
            showBackButton: false,
            leadingIcon: _getLeadingIcon(state.currentIndex),
            actions: [
              if (state.currentIndex == 0 || state.currentIndex == 1) ...[
                IconButton(
                  onPressed: () {
                    // TODO: Implement search
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tìm kiếm')),
                    );
                  },
                  icon: const Icon(Icons.search, color: AppColors.textOnPrimary),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Implement notifications
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thông báo')),
                    );
                  },
                  icon: const Icon(Icons.notifications, color: AppColors.textOnPrimary),
                ),
              ],
              if (state.currentIndex == 2) ...[
                IconButton(
                  onPressed: () {
                    // TODO: Implement category search
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tìm kiếm danh mục')),
                    );
                  },
                  icon: const Icon(Icons.search, color: AppColors.textOnPrimary),
                  tooltip: 'Tìm kiếm danh mục',
                ),
                IconButton(
                  onPressed: () => _showAddCategoryDialog(context),
                  icon: const Icon(Icons.add, color: AppColors.textOnPrimary),
                  tooltip: 'Thêm danh mục',
                ),
              ],
            ],
          ),
          body: _getPageAtIndex(state.currentIndex),
          bottomNavigationBar: DefaultBottomNavBar(
            currentIndex: state.currentIndex,
            onTap: (index) {
              context.read<HomeBloc>().add(ChangeTabEvent(index));
            },
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        onCategoryAdded: (categoryName) {
          // TODO: Add category to state/bloc
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm danh mục: $categoryName'),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

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
          currentList: 'Tất cả',
          onAddTask: () => _handleAddTask(context, state.selectedCategoryId),
        );
      },
    );
  }
}
// TODO: Implement settings tab
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 80,
            color: AppColors.primary,
          ),
          SizedBox(height: 20),
          Text(
            'Cài đặt',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Tùy chỉnh ứng dụng',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
