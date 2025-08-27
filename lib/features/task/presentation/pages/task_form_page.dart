import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaholic/core/di/di.dart';
import 'package:taskaholic/core/themes/app_color.dart';
import 'package:taskaholic/core/utils/task_date_utils.dart';
import 'package:taskaholic/features/task/domain/entities/task_entity.dart';
import 'package:taskaholic/features/task/presentation/bloc/task_bloc.dart';
import 'package:taskaholic/features/task/presentation/bloc/task_event.dart';
import 'package:taskaholic/features/task/presentation/bloc/task_state.dart';
import 'package:taskaholic/features/task/presentation/widgets/category_dropdown.dart';
import 'package:taskaholic/features/task/presentation/widgets/repeat_dropdown.dart';

class TaskFormPage extends StatelessWidget {
  final String? initialCategory;

  const TaskFormPage({
    super.key,
    this.initialCategory,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TaskBloc>(),
      child: _TaskFormContent(initialCategory: initialCategory),
    );
  }
}

class _TaskFormContent extends StatefulWidget {
  final String? initialCategory;
  
  const _TaskFormContent({this.initialCategory});
  
  @override
  State<_TaskFormContent> createState() => _TaskFormContentState();
}

class _TaskFormContentState extends State<_TaskFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedRepeat = 'Không lặp lại';
  String? _selectedList;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedList = widget.initialCategory;
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.backgroundDark,
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
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.backgroundDark,
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
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Create task entity with unique ID
    final task = TaskEntity(
      id: '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}',
      title: _taskController.text.trim(),
      date: _selectedDate,
      time: _selectedTime,
      repeat: _selectedRepeat,
      category: _selectedList,
      isCompleted: false,
      updatedAt: DateTime.now(),
    );

    // Add task through TaskBloc
    context.read<TaskBloc>().add(AddTaskEvent(task));
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('Xác nhận xóa', style: TextStyle(color: AppColors.textOnPrimary)),
        content: const Text(
          'Bạn có chắc chắn muốn xóa nhiệm vụ này?',
          style: TextStyle(color: AppColors.textOnPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: AppColors.textOnPrimary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskActionSuccess) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            
            // Show success message first
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 1),
              ),
            );
            
            // Add small delay to ensure task is fully saved before closing
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                Navigator.pop(context);
              }
            });
          }
        } else if (state is TaskError) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.message}'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      child: AddTaskUI(
      taskController: _taskController,
      selectedDate: _selectedDate,
      selectedTime: _selectedTime,
      selectedRepeat: _selectedRepeat,
      selectedList: _selectedList,
      isLoading: _isLoading,
      isEditing: false,
      formKey: _formKey,
      onSave: _handleSave,
      onDelete: _handleDelete,
      onSelectDate: _selectDate,
      onSelectTime: _selectTime,
      onRepeatChange: (value) {
        setState(() {
          _selectedRepeat = value ?? 'Không lặp lại';
        });
      },
      onCategoryChange: (value) {
        setState(() {
          _selectedList = value;
        });
      },
      ),
    );
  }
}

class AddTaskUI extends StatelessWidget {
  final TextEditingController taskController;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String selectedRepeat;
  final String? selectedList;
  final bool isLoading;
  final bool isEditing;
  final GlobalKey<FormState> formKey;
  final Function() onSave;
  final Function() onDelete;
  final Function() onSelectDate;
  final Function() onSelectTime;
  final Function(String?) onRepeatChange;
  final Function(String?) onCategoryChange;

  const AddTaskUI({
    super.key,
    required this.taskController,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedRepeat,
    required this.selectedList,
    required this.isLoading,
    required this.isEditing,
    required this.formKey,
    required this.onSave,
    required this.onDelete,
    required this.onSelectDate,
    required this.onSelectTime,
    required this.onRepeatChange,
    required this.onCategoryChange,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Chỉnh sửa nhiệm vụ' : 'Nhiệm vụ mới',
              style: const TextStyle(color: AppColors.textOnPrimary, fontSize: 18),
            ),
            if (!isEditing && selectedList != null)
              Text(
                'trong "$selectedList"',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
          ],
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: onDelete,
            ),
          IconButton(
            icon: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.check, color: Colors.white),
            onPressed: isLoading ? null : onSave,
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: taskController,
                  style: const TextStyle(color: AppColors.textOnPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề nhiệm vụ *',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    hintText: 'Nhập tiêu đề nhiệm vụ',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.textSecondary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Vui lòng nhập tiêu đề nhiệm vụ' : null,
                ),
                const SizedBox(height: 20),

                // Date Picker
                InkWell(
                  onTap: onSelectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ngày',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textSecondary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      suffixIcon: Icon(Icons.calendar_today, color: AppColors.textSecondary),
                    ),
                    child: Text(
                      selectedDate != null
                          ? TaskDateUtils.getFormattedDate(selectedDate!)
                          : 'Chọn ngày',
                      style: TextStyle(
                        color: selectedDate != null ? AppColors.textOnPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Time Picker
                InkWell(
                  onTap: onSelectTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Giờ',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textSecondary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      suffixIcon: Icon(Icons.access_time, color: AppColors.textSecondary),
                    ),
                    child: Text(
                      selectedTime != null
                          ? selectedTime!.format(context)
                          : 'Chọn giờ',
                      style: TextStyle(
                        color: selectedTime != null ? AppColors.textOnPrimary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Repeat Dropdown
                RepeatDropdown(
                  selectedRepeat: selectedRepeat,
                  onChanged: onRepeatChange,
                  isDarkMode: true,
                ),
                const SizedBox(height: 20),

                // Category Dropdown
                CategoryDropdown(
                  selectedCategory: selectedList,
                  onChanged: onCategoryChange,
                  hint: 'Chọn danh mục',
                  isDarkMode: true,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: AppColors.textOnPrimary)
                        : Text(
                            isEditing ? 'Cập nhật nhiệm vụ' : 'Tạo nhiệm vụ',
                            style: const TextStyle(color: AppColors.textOnPrimary),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}