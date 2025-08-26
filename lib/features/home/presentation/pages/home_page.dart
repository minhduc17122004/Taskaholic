import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaholic/core/themes/app_color.dart';
import 'package:taskaholic/features/home/presentation/widgets/app_bar.dart';
import 'package:taskaholic/features/home/presentation/widgets/empty_state.dart';
import 'package:taskaholic/features/home/presentation/bloc/home_bloc.dart';
import 'package:taskaholic/features/home/presentation/bloc/home_event.dart';
import 'package:taskaholic/features/home/presentation/bloc/home_state.dart';
import 'package:taskaholic/features/home/presentation/pages/completed_page.dart';
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
        return const _CategoryTab();
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
            title: state.currentIndex == 0 ? 'Danh sách tất cả' : _titles[state.currentIndex],
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
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  void _handleAddTask(BuildContext context) {
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
      currentList: 'Tất cả',
      onAddTask: () => _handleAddTask(context),
    );
  }
}
// TODO: Implement category tab
class _CategoryTab extends StatelessWidget {
  const _CategoryTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category,
            size: 80,
            color: AppColors.primary,
          ),
          SizedBox(height: 20),
          Text(
            'Danh mục',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Quản lý danh mục công việc',
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
