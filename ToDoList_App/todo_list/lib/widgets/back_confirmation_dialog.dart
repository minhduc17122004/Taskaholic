import 'package:flutter/material.dart';

class BackConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String stayText;
  final String discardText;
  final VoidCallback onDiscard;
  
  const BackConfirmationDialog({
    super.key,
    this.title = 'Thay đổi chưa được lưu',
    this.content = 'Bạn có muốn bỏ qua các thay đổi chưa được lưu?',
    this.stayText = 'Ở LẠI',
    this.discardText = 'BỎ QUA',
    required this.onDiscard,
  });
  
  /// Static method to show the unsaved changes confirmation dialog
  /// 
  /// [context] - The build context
  /// [title] - Dialog title
  /// [content] - Dialog content message
  /// [stayText] - Text for the stay button
  /// [discardText] - Text for the discard button
  /// [onDiscard] - Callback when user chooses to discard changes
  static Future<bool?> show({
    required BuildContext context,
    String title = 'Thay đổi chưa được lưu',
    String content = 'Bạn có muốn bỏ qua các thay đổi chưa được lưu?',
    String stayText = 'Ở LẠI',
    String discardText = 'BỎ QUA',
    required VoidCallback onDiscard,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => BackConfirmationDialog(
        title: title,
        content: content,
        stayText: stayText,
        discardText: discardText,
        onDiscard: onDiscard,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 24, 146, 222),
              ),
            ),
          ),
        ],
      ),
      content: Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
      actions: [
        // Stay button
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // Return false (don't discard)
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 80, 78, 78),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            stayText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Discard button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true); // Return true (discard changes)
            onDiscard(); // Execute the discard action
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            discardText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
} 