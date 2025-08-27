import 'package:flutter/material.dart';
import 'package:taskaholic/core/themes/app_color.dart';
import 'package:taskaholic/core/utils/category_constants.dart';

/// CategoryTitleDropdown - Widget chuyên dùng cho AppBar title
/// Có thể kế thừa cho home và completed page
class CategoryTitleDropdown extends StatelessWidget {
  final String selectedCategoryId;
  final Function(String categoryId, String categoryName) onCategoryChanged;
  final bool showTaskCount;
  final int? taskCount;

  const CategoryTitleDropdown({
    super.key,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    this.showTaskCount = false,
    this.taskCount,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCategory = CategoryConstants.getCategoryById(selectedCategoryId) ?? 
                            CategoryConstants.defaultCategories.first;

    return GestureDetector(
      onTap: () => _showCategorySelector(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category Icon
          Icon(
            selectedCategory.icon,
            color: AppColors.textOnPrimary,
            size: 24,
          ),
          const SizedBox(width: 8),
          
          // Category Name + Task Count
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedCategory.name,
                style: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showTaskCount && taskCount != null)
                Text(
                  '$taskCount nhiệm vụ',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
          
          // Dropdown Arrow
          const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textOnPrimary,
            size: 20,
          ),
        ],
      ),
    );
  }

  void _showCategorySelector(BuildContext context) {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<CategoryData>(
      context: context,
      position: position,
      color: AppColors.backgroundDark,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      items: CategoryConstants.defaultCategories.map((category) {
        final isSelected = category.id == selectedCategoryId;
        
        return PopupMenuItem<CategoryData>(
          value: category,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primary.withValues(alpha: 0.1) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Category Icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Category Name
                Expanded(
                  child: Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textOnPrimary,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                
                // Selected Indicator
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 16,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    ).then((selectedCategory) {
      if (selectedCategory != null) {
        onCategoryChanged(selectedCategory.id, selectedCategory.name);
      }
    });
  }
}

/// Simplified version cho cases không cần dropdown (chỉ hiển thị)
class CategoryTitle extends StatelessWidget {
  final String selectedCategoryId;
  final bool showTaskCount;
  final int? taskCount;

  const CategoryTitle({
    super.key,
    required this.selectedCategoryId,
    this.showTaskCount = false,
    this.taskCount,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCategory = CategoryConstants.getCategoryById(selectedCategoryId) ?? 
                            CategoryConstants.defaultCategories.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Category Icon
        Icon(
          selectedCategory.icon,
          color: AppColors.textOnPrimary,
          size: 24,
        ),
        const SizedBox(width: 8),
        
        // Category Name + Task Count
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedCategory.name,
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showTaskCount && taskCount != null)
              Text(
                '$taskCount nhiệm vụ',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
