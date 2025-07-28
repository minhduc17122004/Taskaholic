import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/lists_data.dart';
import '../domain/entities/task.dart';
import '../presentation/bloc/task/task_bloc.dart';
import '../presentation/bloc/task/task_event.dart';
import '../widgets/add_list_dialog.dart';

import '../widgets/custom_repeat_dialog.dart';
import '../widgets/delete_confirmation_dialog.dart';
import '../utils/date_format_utils.dart';

class AddTaskScreen extends StatefulWidget {
  final Task?
  existingTask; // Task hiện có để chỉnh sửa, có thể là null nếu tạo mới
  final String? initialList; // Danh sách ban đầu khi tạo task mới
  
  const AddTaskScreen({
    super.key,
    this.existingTask, // Có thể là null khi tạo mới task
    this.initialList,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState(); //  khởi tạo đối tượng
  // trả về một đối tượng của lớp _AddTaskScreenState
  // lớp này sẽ quản lý trạng thái của widget AddTaskScreen
  // và sẽ được gọi khi widget này được tạo ra
  // lớp này sẽ kế thừa từ State<AddTaskScreen>
  // và sẽ có các phương thức để quản lý trạng thái của widget này
  // và sẽ có các thuộc tính để lưu trữ trạng thái của widget này
  // và sẽ có các phương thức để xây dựng giao diện của widget này
  // và sẽ có các phương thức để xử lý các sự kiện của widget này
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  // kế thừa từ State<AddTaskScreen>
  final TextEditingController _taskController =
      TextEditingController(); // Controller để quản lý nội dung của TextField
  DateTime? _selectedDate; // Biến để lưu ngày đã chọn
  TimeOfDay? _selectedTime; // Biến để lưu giờ đã chọn
  String _selectedRepeat = 'Không lặp lại'; // Biến để lưu kiểu lặp lại đã chọn
  // Danh sách các tùy chọn lặp lại
  final List<String> _repeatOptions = [
    'Không lặp lại',
    'Hàng ngày',
    'Hàng tuần (Thứ 2-Thứ 6)',
    'Hàng tuần',
    'Hàng tháng',
    'Hàng năm',
    'Khác...',
  ];
  String? _selectedList; // Biến để lưu danh sách đã chọn
  String? _taskId; // Thêm biến để lưu ID của task đang chỉnh sửa

  @override
  void initState() {
    super.initState();

    // Kiểm tra xem có phải là chỉnh sửa task hay không
    if (widget.existingTask != null) {
      // Gán dữ liệu từ task hiện có vào các trường
      _taskController.text = widget.existingTask!.title; // Gán tiêu đề task
      _selectedDate = widget.existingTask!.date; // Gán ngày task
      _selectedTime = widget.existingTask!.time; // Gán giờ task
      _selectedRepeat = widget.existingTask!.repeat; // Gán kiểu lặp lại task
      _selectedList = widget.existingTask!.list; // Gán danh sách hiện tại
      _taskId = widget.existingTask!.id; // Lưu ID của task hiện có
    } else {
      // Nếu là tạo mới, khởi tạo giá trị mặc định
      _selectedList = widget.initialList ?? 
          ListsData.getAddTaskListOptions()[0]; // Lấy item đầu tiên của danh sách dành cho màn hình thêm task
    }
  }

  // Hiển thị dialog thêm danh sách
  void _showAddListDialog() {
    final controller =
        TextEditingController(); // tạo một textediting controller mới dùng để điều khiển và lấy dl từ textfield
    showDialog(
      context: context, // tham số ngữ cảnh widget hiện tại
      builder: (BuildContext context) {
        // hàm trả về giao diện của dialog có tên là AddListDialog
        return AddListDialog(
          controller:
              controller, // Truyền TextEditingController vào cho TextField
          onListAdded: (String newList) {
            // Truyền một callback để xử lý khi người dùng nhấn nút "Thêm danh sách".
            setState(() {
              _selectedList = newList;
            });
          },
        );
      },
    );
  }

  // Hiển thị dialog lặp lại
  void _showCustomRepeatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomRepeatDialog(
          onRepeatSet: (number, unit) {
            // Truyền một callback để xử lý khi người dùng nhấn nút "Lặp lại".
            // number là số lần lặp lại
            // unit là đơn vị lặp lại (ngày, tuần, tháng, năm)
            final customValue = 'Khác ($number $unit)'; // Tạo giá trị tùy chỉnh
            setState(() {
              _repeatOptions.removeWhere(
                (item) => item.startsWith('Khác ('),
              ); // Xóa các tùy chọn khác
              _repeatOptions.insert(0, customValue); // Thêm tùy chọn mới
              _selectedRepeat = customValue; // Cập nhật giá trị đã chọn
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing =
        widget.existingTask !=
        null; // Kiểm tra xem có phải là chỉnh sửa task hay không

    // Đảm bảo dropdown luôn chứa giá trị _selectedList
    List<String> dropdownListOptions = List.from(ListsData.getAddTaskListOptions());
    if (_selectedList != null && !dropdownListOptions.contains(_selectedList)) {
      dropdownListOptions.add(_selectedList!);
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 45, 81),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 115, 182),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Kiểm tra xem có thay đổi nào không
            bool hasChanges = false;

            if (widget.existingTask != null) {
              // Trường hợp chỉnh sửa - so sánh với task gốc
              hasChanges =
                  _taskController.text !=
                      widget.existingTask!.title || // so sánh tiêu đề
                  _selectedDate?.day != widget.existingTask!.date.day ||
                  _selectedDate?.month != widget.existingTask!.date.month ||
                  _selectedDate?.year != widget.existingTask!.date.year ||
                  _selectedTime?.format(context) !=
                      widget.existingTask!.time.format(context) ||
                  _selectedRepeat != widget.existingTask!.repeat ||
                  _selectedList !=
                      (widget.existingTask!.list == 'Kết thúc'
                          ? widget.existingTask!.originalList
                          : widget.existingTask!.list);
            } else {
              // Trường hợp thêm mới - kiểm tra xem có nhập dữ liệu gì chưa
              hasChanges =
                  _taskController.text.isNotEmpty ||
                  _selectedDate != null ||
                  _selectedTime != null ||
                  _selectedRepeat != 'Không lặp lại' ||
                  _selectedList != (widget.initialList ?? ListsData.getAddTaskListOptions()[0]);
            }
          },
        ),
        title: Text(
          isEditing ? 'Chỉnh sửa nhiệm vụ' : 'Nhiệm vụ mới',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Chỉ hiển thị nút xóa khi đang chỉnh sửa task
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                // Hiển thị dialog xác nhận xóa
                DeleteConfirmationDialog.show(
                  context: context,
                  onConfirm: () {
                    // Xóa task
                    if (_taskId != null) {
                      context.read<TaskBloc>().add(DeleteTaskEvent(_taskId!));
                    }
                    Navigator.pop(context); // Quay lại màn hình trước
                  },
                );
              },
            ),
          // Nút lưu
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              // Kiểm tra xem tiêu đề có trống không
              if (_taskController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập tiêu đề nhiệm vụ'),
                  ),
                );
                return;
              }

              // Lấy ngày và giờ hiện tại nếu không có ngày và giờ được chọn
              final now = DateTime.now();
              final date = _selectedDate ?? now;
              final time = _selectedTime ?? TimeOfDay.now();

              if (isEditing && _taskId != null) {
                // Cập nhật task
                final updatedTask = Task(
                  id: _taskId!,
                  title: _taskController.text,
                  date: date,
                  time: time,
                  repeat: _selectedRepeat,
                  list: _selectedList ?? 'Công việc',
                  originalList: _selectedList ?? 'Công việc',
                  isCompleted: widget.existingTask!.isCompleted,
                );
                context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));
              } else {
                // Tạo task mới
                final newTask = Task(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _taskController.text,
                  date: date,
                  time: time,
                  repeat: _selectedRepeat,
                  list: _selectedList ?? 'Công việc',
                  originalList: _selectedList ?? 'Công việc',
                  isCompleted: false,
                );
                context.read<TaskBloc>().add(AddTaskEvent(newTask));
                    }

              Navigator.pop(context); // Quay lại màn hình trước
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trường nhập tiêu đề
              TextField(
                controller: _taskController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: 'Nhập tiêu đề nhiệm vụ',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white60),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white60),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 1, 115, 182), width: 2),
                ),
              ),
              ),
              const SizedBox(height: 20),

              // Chọn ngày
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                      decoration: const InputDecoration(
                    labelText: 'Ngày',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white60),
                        ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white60),
                        ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 1, 115, 182), width: 2),
                    ),
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.white70),
                        ),
                        child: Text(
                    _selectedDate != null
                        ? DateFormatUtils.formatDate(_selectedDate!)
                        : 'Chọn ngày',
                          style: TextStyle(
                      fontSize: 16,
                      color: _selectedDate != null ? Colors.white : Colors.white60,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),

              // Chọn giờ
              InkWell(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime ?? TimeOfDay.now(),
                  );
                  if (picked != null && picked != _selectedTime) {
                          setState(() {
                      _selectedTime = picked;
                          });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Giờ',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white60),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white60),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 1, 115, 182), width: 2),
                    ),
                    suffixIcon: Icon(Icons.access_time, color: Colors.white70),
                          ),
                          child: Text(
                            _selectedTime != null
                                ? _selectedTime!.format(context)
                                : 'Chọn giờ',
                            style: TextStyle(
                      fontSize: 16,
                      color: _selectedTime != null ? Colors.white : Colors.white60,
                            ),
                          ),
                        ),
                      ),
              const SizedBox(height: 20),

              // Chọn kiểu lặp lại
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Lặp lại',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white60),
              ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white60),
                ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 1, 115, 182), width: 2),
                  ),
                ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRepeat,
                    isExpanded: true,
                    dropdownColor: const Color.fromARGB(255, 1, 63, 113),
                    style: const TextStyle(color: Colors.white),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                    items: _repeatOptions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                          style: const TextStyle(color: Colors.white),
                                  ),
                                );
                    }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue == 'Khác...') {
                                _showCustomRepeatDialog();
                              } else {
                                setState(() {
                                  _selectedRepeat = newValue!;
                                });
                              }
                            },
                          ),
                        ),
                      ),
              const SizedBox(height: 20),

              // Chọn danh sách
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Danh sách',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white60),
              ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white60),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 1, 115, 182), width: 2),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedList,
                          isExpanded: true,
                          dropdownColor: const Color.fromARGB(255, 1, 63, 113),
                          style: const TextStyle(color: Colors.white),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                          items: dropdownListOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                value,
                                style: const TextStyle(color: Colors.white),
                                ),
                              );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedList = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: _showAddListDialog,
                    ),
                  ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
