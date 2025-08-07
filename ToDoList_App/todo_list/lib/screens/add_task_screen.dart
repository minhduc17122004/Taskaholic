import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../data/lists_data.dart';
import '../domain/entities/task.dart';
import '../presentation/bloc/task/task_bloc.dart';
import '../presentation/bloc/task/task_event.dart';
import '../utils/date_format_utils.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? existingTask;
  final String? initialList;
  
  const AddTaskScreen({
    super.key,
    this.existingTask,
    this.initialList,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _taskController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedRepeat = 'Không lặp lại';
  String? _selectedList;
  String? _taskId;
  bool _isLoading = false;

  final List<String> _repeatOptions = [
    'Không lặp lại',
    'Hàng ngày',
    'Hàng tuần (Thứ 2-Thứ 6)',
    'Hàng tuần',
    'Hàng tháng',
    'Hàng năm',
  ];

  // Original values for change detection
  String _originalTitle = '';
  DateTime? _originalDate;
  TimeOfDay? _originalTime;
  String _originalRepeat = 'Không lặp lại';
  String? _originalList;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    developer.log('AddTaskScreen initState called', name: 'AddTaskScreen');
    developer.log('existingTask: ${widget.existingTask != null ? "editing" : "creating new"}', name: 'AddTaskScreen');
    developer.log('initialList: ${widget.initialList}', name: 'AddTaskScreen');

    if (widget.existingTask != null) {
      // Editing existing task
      final task = widget.existingTask!;
      _originalTitle = task.title;
      _originalDate = task.date;
      _originalTime = task.time;
      _originalRepeat = task.repeat;
      _originalList = task.list;

      _taskController.text = task.title;
      _selectedDate = task.date;
      _selectedTime = task.time;
      _selectedRepeat = task.repeat;
      _selectedList = task.list;
      _taskId = task.id;
    } else {
      // Creating new task
      try {
        final categories = ListsData.getAddTaskListOptions();
        
        if (widget.initialList != null) {
          if (ListsData.isValidCategoryForAssignment(widget.initialList!)) {
            _selectedList = widget.initialList;
          } else {
            _selectedList = categories.isNotEmpty ? categories[0] : 'Mặc định';
          }
        } else {
          _selectedList = categories.isNotEmpty ? categories[0] : 'Mặc định';
        }
        
        _originalList = _selectedList;
        developer.log('Initialized category: $_selectedList', name: 'AddTaskScreen');
      } catch (e) {
        _selectedList = 'Mặc định';
        _originalList = _selectedList;
        developer.log('Error initializing category: $e', name: 'AddTaskScreen');
      }
    }
  }

  bool get hasUnsavedChanges {
    if (widget.existingTask != null) {
      return _taskController.text != _originalTitle ||
          !_areDatesEqual(_selectedDate, _originalDate) ||
          !_areTimesEqual(_selectedTime, _originalTime) ||
          _selectedRepeat != _originalRepeat ||
          _selectedList != _originalList;
    } else {
      return _taskController.text.isNotEmpty ||
          _selectedDate != null ||
          _selectedTime != null ||
          _selectedRepeat != 'Không lặp lại' ||
          _selectedList != _originalList;
    }
  }

  bool _areDatesEqual(DateTime? date1, DateTime? date2) {
    if (date1 == null && date2 == null) return true;
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _areTimesEqual(TimeOfDay? time1, TimeOfDay? time2) {
    if (time1 == null && time2 == null) return true;
    if (time1 == null || time2 == null) return false;
    return time1.hour == time2.hour && time1.minute == time2.minute;
  }

  Future<bool> _onWillPop() async {
    if (!hasUnsavedChanges) {
      return true;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 1, 63, 113),
          title: const Text(
            'Thay đổi chưa được lưu',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            widget.existingTask != null
                ? 'Bạn có các thay đổi chưa được lưu. Bạn có muốn bỏ qua các thay đổi này?'
                : 'Bạn đang tạo một nhiệm vụ mới. Bạn có muốn bỏ qua và thoát?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Ở LẠI',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'BỎ QUA',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    return shouldDiscard ?? false;
  }

  void _handleDeleteTask() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 1, 63, 113),
          title: const Text(
            'XÁC NHẬN XOÁ NHIỆM VỤ',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa nhiệm vụ "${_taskController.text}"?\n\nHành động này không thể hoàn tác.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'HUỶ',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                if (_taskId != null) {
                  context.read<TaskBloc>().add(DeleteTaskEvent(_taskId!));
                }
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close screen
              },
              child: const Text(
                'XOÁ',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleSaveTask() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_taskController.text.trim().isEmpty) {
      _showErrorMessage('Vui lòng nhập tiêu đề nhiệm vụ');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final date = _selectedDate ?? now;
      final time = _selectedTime ?? TimeOfDay.now();
      
      String list;
      if (_selectedList == null || _selectedList!.isEmpty) {
        list = 'Mặc định';
      } else if (!ListsData.isValidCategoryForAssignment(_selectedList!)) {
        final categories = ListsData.getAddTaskListOptions();
        list = categories.isNotEmpty ? categories[0] : 'Mặc định';
      } else {
        list = _selectedList!;
      }
      
      developer.log('Saving task with category: $list', name: 'AddTaskScreen');

      if (widget.existingTask != null && _taskId != null) {
        // Update existing task
        final updatedTask = Task(
          id: _taskId!,
          title: _taskController.text.trim(),
          date: date,
          time: time,
          repeat: _selectedRepeat,
          list: list,
          originalList: widget.existingTask!.originalList,
          isCompleted: widget.existingTask!.isCompleted,
        );
        context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));
        
        _showSuccessMessage('Nhiệm vụ đã được cập nhật');
      } else {
        // Create new task
        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _taskController.text.trim(),
          date: date,
          time: time,
          repeat: _selectedRepeat,
          list: list,
          originalList: list,
          isCompleted: false,
        );
        context.read<TaskBloc>().add(AddTaskEvent(newTask));
        
        _showSuccessMessage('Nhiệm vụ đã được tạo');
      }

      // Wait a bit for the operation to complete, then navigate back
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorMessage('Lỗi khi lưu nhiệm vụ: $e');
      developer.log('Error saving task: $e', name: 'AddTaskScreen');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.existingTask != null;
    
    // Ensure dropdown always contains _selectedList
    List<String> dropdownListOptions = [];
    try {
      dropdownListOptions = List.from(ListsData.getAddTaskListOptions());
      
      if (dropdownListOptions.isEmpty) {
        dropdownListOptions.add('Mặc định');
      }
      
      if (_selectedList != null && !dropdownListOptions.contains(_selectedList)) {
        if (_selectedList != null && ListsData.isValidCategoryForAssignment(_selectedList!)) {
          dropdownListOptions.add(_selectedList!);
        } else {
          _selectedList = dropdownListOptions.isNotEmpty ? dropdownListOptions.first : 'Mặc định';
        }
      }
    } catch (e) {
      dropdownListOptions = ['Mặc định'];
      _selectedList = 'Mặc định';
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 1, 45, 81),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 1, 115, 182),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              final canPop = await _onWillPop();
              if (canPop) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditing ? 'Chỉnh sửa nhiệm vụ' : 'Nhiệm vụ mới',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              if (!isEditing && _selectedList != null)
                Text(
                  'trong "$_selectedList"',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          actions: [
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                tooltip: 'Xóa nhiệm vụ',
                onPressed: _handleDeleteTask,
              ),
            IconButton(
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check, color: Colors.white),
              tooltip: 'Lưu nhiệm vụ',
              onPressed: _isLoading ? null : _handleSaveTask,
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title field
                  TextFormField(
                    controller: _taskController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Tiêu đề nhiệm vụ *',
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
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                      errorStyle: TextStyle(color: Colors.red),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tiêu đề nhiệm vụ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Date picker
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color.fromARGB(255, 1, 115, 182),
                                onPrimary: Colors.white,
                                surface: Color.fromARGB(255, 1, 63, 113),
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
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

                  // Time picker
                  InkWell(
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime ?? TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color.fromARGB(255, 1, 115, 182),
                                onPrimary: Colors.white,
                                surface: Color.fromARGB(255, 1, 63, 113),
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
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

                  // Repeat dropdown
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
                          if (newValue != null) {
                            setState(() {
                              _selectedRepeat = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category dropdown
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Danh mục',
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
                          if (newValue != null) {
                            setState(() {
                              _selectedList = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit button at the bottom
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSaveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 1, 115, 182),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Đang lưu...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              isEditing ? 'Cập nhật nhiệm vụ' : 'Tạo nhiệm vụ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 