import 'package:flutter/material.dart';

class BackConfirmationDialog extends StatelessWidget {
  final String actionType;
  final VoidCallback onConfirm;

  const BackConfirmationDialog({
    super.key,
    required this.actionType,
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required String actionType,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return BackConfirmationDialog(
          actionType: actionType,
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
        'Hủy thay đổi?',
        style: TextStyle(color: Colors.white),
      ),
      content: Text(
        'Bạn có chắc muốn hủy việc $actionType công việc này? Các thay đổi sẽ không được lưu.',
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Tiếp tục chỉnh sửa',
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
            'Hủy thay đổi',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
} 