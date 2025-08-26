import 'package:flutter/material.dart';
import 'package:taskaholic/core/themes/app_color.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.task_alt, size: 80, color: AppColors.background),
        const SizedBox(height: 8),
        const Text(
          'TASKAHOLIC',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.background),
        ),
        const SizedBox(height: 32),    
      ],
    );
  }
}
