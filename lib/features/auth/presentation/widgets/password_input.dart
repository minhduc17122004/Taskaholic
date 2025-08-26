import 'package:flutter/material.dart';
import 'package:taskaholic/core/themes/app_color.dart';

class PasswordInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onToggle;
  final String label;
  final String? Function(String?)? validator;
  final TextEditingController? matchController; // optional - used for confirm password

  const PasswordInput({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.onToggle,
    required this.label,
    this.validator,
    this.matchController,
  });

  OutlineInputBorder _defaultBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBackgroundDark),
      );

  OutlineInputBorder _focusedBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      );

  OutlineInputBorder _errorBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(color: AppColors.background),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textPrimaryDark),
        prefixIcon: const Icon(Icons.lock, color: AppColors.textPrimaryDark),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.textPrimaryDark,
          ),
          onPressed: onToggle,
        ),
        enabledBorder: _defaultBorder(),
        focusedBorder: _focusedBorder(),
        errorBorder: _errorBorder(),
        focusedErrorBorder: _focusedBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập $label'.toLowerCase();
        }
        if (value.length < 6) {
          return '$label phải có ít nhất 6 ký tự';
        }
        if (matchController != null && value != matchController!.text) {
          return '$label không khớp';
        }
        return validator?.call(value);
      },
    );
  }
}
