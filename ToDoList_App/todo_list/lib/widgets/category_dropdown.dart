import 'package:flutter/material.dart';
import '../data/lists_data.dart';

class CategoryDropdown extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;
  final String hint;
  final bool showIcons;
  final bool showColors;

  const CategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
    this.hint = 'Chọn danh mục',
    this.showIcons = true,
    this.showColors = true,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách danh mục và đảm bảo không rỗng
    List<String> categories = [];
    try {
      categories = ListsData.getAddTaskListOptions();
      // Đảm bảo luôn có ít nhất một danh mục
      if (categories.isEmpty) {
        categories.add('Mặc định');
      }
      
      // Đảm bảo selectedCategory nằm trong danh sách
      if (selectedCategory != null && !categories.contains(selectedCategory)) {
        if (ListsData.isValidCategoryForAssignment(selectedCategory!)) {
          categories.add(selectedCategory!);
        }
      }
    } catch (e) {
      // Trường hợp lỗi, sử dụng danh mục mặc định
      categories = ['Mặc định'];
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 40, 90, 130),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 1, 115, 182),
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        hint: Text(hint, style: const TextStyle(color: Colors.white70)),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        dropdownColor: const Color.fromARGB(255, 40, 90, 130),
        style: const TextStyle(color: Colors.white),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
        items:
            categories.map<DropdownMenuItem<String>>((String category) {
              final categoryColor =
                  showColors ? ListsData.getCategoryColor(category) : null;
              final categoryIcon =
                  showIcons ? ListsData.getCategoryIcon(category) : null;

              return DropdownMenuItem<String>(
                value: category,
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Đảm bảo Row có kích thước tối thiểu
                  children: [
                    if (showColors && categoryColor != null) ...[
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (showIcons && categoryIcon != null) ...[
                      Icon(
                        categoryIcon,
                        color: categoryColor ?? Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        category,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null &&
              ListsData.isValidCategoryForAssignment(newValue)) {
            onChanged(newValue);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng chọn danh mục';
          }
          if (!ListsData.isValidCategoryForAssignment(value)) {
            return 'Danh mục không hợp lệ';
          }
          return null;
        },
      ),
    );
  }
}

/// A simple category chip widget for displaying category information
class CategoryChip extends StatelessWidget {
  final String categoryName;
  final bool showIcon;
  final bool showColor;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CategoryChip({
    super.key,
    required this.categoryName,
    this.showIcon = true,
    this.showColor = true,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor =
        showColor ? ListsData.getCategoryColor(categoryName) : null;
    final categoryIcon =
        showIcon ? ListsData.getCategoryIcon(categoryName) : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              categoryColor?.withValues(alpha: 0.2) ?? Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                categoryColor?.withValues(alpha: 0.5) ?? Colors.grey.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon && categoryIcon != null) ...[
              Icon(categoryIcon, color: categoryColor ?? Colors.grey, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              categoryName,
              style: TextStyle(
                color: categoryColor ?? Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  color: categoryColor ?? Colors.grey,
                  size: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A category selector widget that shows categories in a grid
class CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final bool allowSystemCategories;

  const CategorySelector({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
    this.allowSystemCategories = false,
  });

  @override
  Widget build(BuildContext context) {
    final categories =
        allowSystemCategories
            ? ListsData.getAllDisplayCategories()
            : ListsData.getSelectableCategories();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          categories.map((category) {
            final isSelected = category == selectedCategory;
            final categoryColor = ListsData.getCategoryColor(category);
            final categoryIcon = ListsData.getCategoryIcon(category);

            return GestureDetector(
              onTap: () => onCategorySelected(category),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? categoryColor.withValues(alpha: 0.3)
                          : categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected
                            ? categoryColor
                            : categoryColor.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(categoryIcon, color: categoryColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: TextStyle(
                        color: categoryColor,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
