import 'package:flutter/material.dart';
import 'package:taskaholic/core/themes/app_color.dart';

class EmailInput extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const EmailInput({
    required this.controller,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: const TextStyle(color: AppColors.textPrimaryDark),
        prefixIcon: const Icon(Icons.email),
        enabledBorder: _border(),
        focusedBorder: _focusedBorder(),
        errorBorder: _errorBorder(),
        focusedErrorBorder: _focusedBorder(),
      ),
      validator: validator ?? _defaultEmailValidator,
    );
  }

  OutlineInputBorder _border() => OutlineInputBorder(
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

  String? _defaultEmailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Email không hợp lệ';
    }
    return null;
  }
}
