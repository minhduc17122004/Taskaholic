import 'dart:async';
import 'package:flutter/material.dart';
import '../data/lists_data.dart';
import '../core/services/category_notifier.dart';
import '../core/di/injection_container.dart' as di;

class ReactiveCategoryDropdown extends StatefulWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;
  final String hint;
  final bool showIcons;
  final bool showColors;

  const ReactiveCategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
    this.hint = 'Chọn danh mục',
    this.showIcons = true,
    this.showColors = true,
  });

  @override
  State<ReactiveCategoryDropdown> createState() => _ReactiveCategoryDropdownState();
}

class _ReactiveCategoryDropdownState extends State<ReactiveCategoryDropdown> {
  late List<String> _categories;
  StreamSubscription<CategoryChangeEvent>? _categorySubscription;
  final CategoryNotifier _categoryNotifier = di.sl<CategoryNotifier>();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    
    // Listen for category changes
    _categorySubscription = _categoryNotifier.categoryChanges.listen((event) {
      // Reload categories when they change
      _loadCategories();
    });
  }

  @override
  void dispose() {
    _categorySubscription?.cancel();
    super.dispose();
  }

  void _loadCategories() {
    try {
      final categories = ListsData.getAddTaskListOptions();
      
      // Ensure we have at least one category
      if (categories.isEmpty) {
        categories.add('Công việc');
      }
      
      // Ensure selectedCategory is in the list
      if (widget.selectedCategory != null && !categories.contains(widget.selectedCategory)) {
        if (ListsData.isValidCategoryForAssignment(widget.selectedCategory!)) {
          categories.add(widget.selectedCategory!);
        }
      }
      
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      setState(() {
        _categories = ['Công việc'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        value: widget.selectedCategory,
        hint: Text(widget.hint, style: const TextStyle(color: Colors.white70)),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        dropdownColor: const Color.fromARGB(255, 40, 90, 130),
        style: const TextStyle(color: Colors.white),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
        items: _categories.map<DropdownMenuItem<String>>((String category) {
          final categoryColor = widget.showColors ? ListsData.getCategoryColor(category) : null;
          final categoryIcon = widget.showIcons ? ListsData.getCategoryIcon(category) : null;

          return DropdownMenuItem<String>(
            value: category,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showColors && categoryColor != null) ...[
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
                if (widget.showIcons && categoryIcon != null) ...[
                  Icon(
                    categoryIcon,
                    color: categoryColor ?? Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  category,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null && ListsData.isValidCategoryForAssignment(newValue)) {
            widget.onChanged(newValue);
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