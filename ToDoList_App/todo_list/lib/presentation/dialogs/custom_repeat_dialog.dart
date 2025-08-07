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
  final TextEditingController _numberController = TextEditingController(text: '1');
  String _selectedUnit = 'ngày';
  final List<String> _units = ['ngày', 'tuần', 'tháng', 'năm'];

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 1, 63, 113),
      title: const Text(
        'Lặp lại tùy chỉnh',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Trường nhập số
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Số',
                    hintStyle: TextStyle(color: Colors.white60),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white60),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF80CFFF), width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Dropdown chọn đơn vị
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  dropdownColor: const Color.fromARGB(255, 1, 63, 113),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white60),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF80CFFF), width: 2),
                    ),
                  ),
                  items: _units.map((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedUnit = newValue;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
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
            // Xử lý khi người dùng nhấn nút "Lặp lại"
            final number = int.tryParse(_numberController.text) ?? 1;
            widget.onRepeatSet(number, _selectedUnit);
            Navigator.pop(context);
          },
          child: const Text('Lặp lại', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
} 