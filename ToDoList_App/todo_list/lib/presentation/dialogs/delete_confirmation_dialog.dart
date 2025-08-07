import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          onConfirm: onConfirm,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 1, 63, 113),
      title: const Text(
        'Xóa công việc?',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        'Bạn có chắc muốn xóa công việc này? Hành động này không thể hoàn tác.',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Hủy',
            style: TextStyle(color: Colors.white60),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            Navigator.pop(context); // Đóng dialog
            onConfirm(); // Gọi callback xác nhận
          },
          child: const Text(
            'Xóa',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
} 