import 'package:flutter/material.dart';
import '../../data/lists_data.dart';

class AddListDialog extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onListAdded;

  const AddListDialog({
    Key? key,
    required this.controller,
    required this.onListAdded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 1, 63, 113),
      title: const Text(
        'Danh sách mới',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Nhập tên danh sách',
          hintStyle: TextStyle(color: Colors.white60),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white60),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF80CFFF), width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 1, 115, 182),
          ),
          onPressed: () {
            if (controller.text.isNotEmpty) {
              // Thêm vào cả hai danh sách để đảm bảo tương thích
              ListsData.lists.add(controller.text);
              ListsData.listOptions.add(controller.text);
              
              onListAdded(controller.text);
              controller.clear();
              Navigator.pop(context);
            }
          },
          child: const Text('Thêm', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
} 