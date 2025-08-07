import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String title; // Tiêu đề dialog
  final String content; // Nội dung dialog
  final String cancelText; // Nội dung nút hủy
  final String confirmText; // Nội dung nút xác nhận
  final VoidCallback onConfirm; // Hàm xử lý khi xác nhận xóa
  
  const DeleteConfirmationDialog({
    super.key,
    this.title = 'Xác nhận xóa', // Giá trị mặc định
    this.content = 'Bạn có chắc chắn muốn xóa?', // Giá trị mặc định
    this.cancelText = 'Hủy', // Giá trị mặc định
    this.confirmText = 'Xóa', // Giá trị mặc định
    required this.onConfirm, 
  });
  
  /// Phương thức tĩnh để hiển thị dialog xác nhận xóa
  /// 
  /// [context] là context của ứng dụng
  /// [title] là tiêu đề của dialog
  /// [content] là nội dung của dialog
  /// [cancelText] là nội dung nút hủy
  /// [confirmText] là nội dung nút xác nhận
  /// [onConfirm] là hàm xử lý khi người dùng xác nhận xóa
  static Future<void> show({
    required BuildContext context,
    String title = 'XÁC NHẬN XOÁ',
    String content = 'Bạn có chắc chắn muốn xóa?',
    String cancelText = 'HUỶ',
    String confirmText = 'XOÁ',
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        confirmText: confirmText,
        onConfirm: onConfirm,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: const Color.fromARGB(255, 24, 146, 222)),),
      content: Text(content,style: TextStyle(fontSize: 18)),
      actions: [
        // Nút hủy
        TextButton(
          onPressed: () => Navigator.pop(context), // Đóng dialog
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 80, 78, 78), // Màu chữ trắng cho nút hủy
          ),
          child: Text(cancelText,style: TextStyle(fontSize: 18)),
        ),
        // Nút xác nhận xóa
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Đóng dialog
            onConfirm(); // Thực hiện hành động xóa
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.red, // Màu chữ đỏ cho nút xóa
          ),
          child: Text(confirmText,style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
} 