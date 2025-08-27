import 'package:flutter/material.dart';
import 'package:taskaholic/core/themes/app_color.dart';
import 'package:taskaholic/core/utils/category_constants.dart';

class CategoryDropdown extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onChanged;
  final String hint;
  final bool isDarkMode;

  const CategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
    this.hint = 'Chọn danh mục',
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // Use real categories from CategoryConstants (extracted from remote datasource)
    final taskCategories = CategoryConstants.taskCategories;
    
    // Fix: Ensure selectedCategory exists in taskCategories, otherwise set to null
    final validSelectedCategory = taskCategories
        .any((cat) => cat.name == selectedCategory) 
        ? selectedCategory 
        : null;

    final primaryColor = isDarkMode 
        ? const Color.fromARGB(255, 1, 115, 182)
        : AppColors.primary;
    
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimaryDark;
    final hintColor = isDarkMode ? Colors.white60 : AppColors.textSecondary;
    final borderColor = isDarkMode ? Colors.white60 : AppColors.textSecondary;
    final dropdownColor = isDarkMode 
        ? const Color.fromARGB(255, 1, 63, 113)
        : AppColors.cardBackground;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Danh mục',
        labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : AppColors.textSecondary),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: validSelectedCategory,
          dropdownColor: dropdownColor,
          style: TextStyle(color: textColor),
          icon: Icon(Icons.arrow_drop_down, color: hintColor),
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(color: hintColor),
          ),
          items: taskCategories.map((CategoryData categoryData) {
            return DropdownMenuItem<String>(
              value: categoryData.name,
              child: Row(
                children: [
                  Icon(
                    categoryData.icon,
                    color: hintColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    categoryData.name,
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
