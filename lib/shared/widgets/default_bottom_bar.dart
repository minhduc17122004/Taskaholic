import 'package:flutter/material.dart';
import 'package:taskaholic/core/themes/app_color.dart';

class DefaultBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DefaultBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.primary,
      selectedItemColor: AppColors.cardBackground,
      unselectedItemColor: AppColors.cardBackground.withValues(alpha: 0.6),
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle),
          label: 'Hoàn thành',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Danh mục',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Cài đặt',
        ),
      ],
    );
  }
}
