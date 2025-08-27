import 'package:flutter/material.dart';
import 'package:taskaholic/core/themes/app_color.dart';

class RepeatDropdown extends StatelessWidget {
  final String selectedRepeat;
  final Function(String?) onChanged;
  final bool isDarkMode;

  const RepeatDropdown({
    super.key,
    required this.selectedRepeat,
    required this.onChanged,
    this.isDarkMode = false,
  });

  static const List<String> repeatOptions = [
    'Không lặp lại',
    'Hàng ngày',
    'Hàng ngày (Thứ 2-Thứ 6)',
    'Hàng tuần',
    'Hàng tháng',
    'Hàng năm',
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDarkMode 
        ? const Color.fromARGB(255, 1, 115, 182)
        : AppColors.primary;
    
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimaryDark;
    final hintColor = isDarkMode ? Colors.white70 : AppColors.textSecondary;
    final borderColor = isDarkMode ? Colors.white60 : AppColors.textSecondary;
    final dropdownColor = isDarkMode 
        ? const Color.fromARGB(255, 1, 63, 113)
        : AppColors.cardBackground;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Lặp lại',
        labelStyle: TextStyle(color: hintColor),
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
          value: selectedRepeat,
          dropdownColor: dropdownColor,
          style: TextStyle(color: textColor),
          icon: Icon(Icons.arrow_drop_down, color: hintColor),
          isExpanded: true,
          items: repeatOptions.map((String value) {
            IconData iconData;
            switch (value) {
              case 'Không lặp lại':
                iconData = Icons.event_busy;
                break;
              case 'Hàng ngày':
                iconData = Icons.today;
                break;
              case 'Hàng ngày (Thứ 2-Thứ 6)':
                iconData = Icons.business_center;
                break;
              case 'Hàng tuần':
                iconData = Icons.date_range;
                break;
              case 'Hàng tháng':
                iconData = Icons.calendar_month;
                break;
              case 'Hàng năm':
                iconData = Icons.event_repeat;
                break;
              default:
                iconData = Icons.repeat;
            }

            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(
                    iconData,
                    color: hintColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(color: textColor),
                      overflow: TextOverflow.ellipsis,
                    ),
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
