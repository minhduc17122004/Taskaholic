import 'package:flutter/material.dart';

class CustomRepeatDialog extends StatefulWidget {
  final Function(int, String) onRepeatSet;

  const CustomRepeatDialog({
    super.key,
    required this.onRepeatSet,
  });

  @override
  State<CustomRepeatDialog> createState() => _CustomRepeatDialogState();
}

class _CustomRepeatDialogState extends State<CustomRepeatDialog> {
  int number = 1;
  String unit = 'ngày';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: const Text(
        'Lặp lại',
        style: TextStyle(
          color: Color.fromARGB(255, 24, 146, 222),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Số lượng
          SizedBox(
            width: 60,
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                number = int.tryParse(value) ?? 1;
              },
            ),
          ),
          // Đơn vị thời gian
          DropdownButton<String>(
            value: unit,
            items: const [
              DropdownMenuItem(value: 'ngày', child: Text('ngày')),
              DropdownMenuItem(value: 'tuần', child: Text('tuần')),
              DropdownMenuItem(value: 'tháng', child: Text('tháng')),
              DropdownMenuItem(value: 'năm', child: Text('năm')),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  unit = newValue;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text(
            'HỦY BỎ',
            style: TextStyle(
              color: Color.fromARGB(255, 24, 146, 222),
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text(
            'THIẾT LẬP',
            style: TextStyle(
              color: Color.fromARGB(255, 24, 146, 222),
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            widget.onRepeatSet(number, unit);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}