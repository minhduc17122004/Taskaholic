import 'package:flutter/material.dart';

class EditCategoryDialog extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSave;

  const EditCategoryDialog({
    super.key,
    required this.controller,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required String initialValue,
    required Function(String) onSave,
  }) async {
    final controller = TextEditingController(text: initialValue);
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return EditCategoryDialog(
          controller: controller,
          onSave: onSave,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 1, 63, 113),
      title: const Text(
        'Chỉnh sửa danh mục',
        style: TextStyle(color: Colors.white),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Tên danh mục',
          hintStyle: TextStyle(color: Colors.white60),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white60),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF80CFFF), width: 1.5),
          ),
        ),
        cursorColor: const Color(0xFF80CFFF),
        style: const TextStyle(color: Colors.white),
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
            backgroundColor: const Color.fromARGB(255, 1, 115, 182),
          ),
          onPressed: () {
            final newName = controller.text.trim();
            if (newName.isNotEmpty) {
              onSave(newName);
              Navigator.pop(context);
            }
          },
          child: const Text(
            'Lưu',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
} 