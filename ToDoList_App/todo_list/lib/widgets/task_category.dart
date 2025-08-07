import 'package:flutter/material.dart';
import '../domain/entities/task.dart';
import 'task_item.dart';

class TaskCategory extends StatelessWidget {
  final String categoryName; // Tiêu đề danh mục
  final List<Task> tasks; // Danh sách công việc thuộc danh mục
  final Function(Task) onTaskToggle; // Hàm xử lý khi trạng thái công việc thay đổi
  final Function(String) onTaskDelete; // Hàm xử lý khi xóa task
  final Color titleColor; // Màu sắc cho tiêu đề danh mục
  final bool showListName; // Cờ xác định có hiển thị tên danh sách hay không

  const TaskCategory({
    super.key,
    required this.categoryName,
    required this.tasks,
    required this.onTaskToggle,
    required this.onTaskDelete,
    this.titleColor = Colors.white, // Màu mặc định cho tiêu đề là trắng
    this.showListName = false, // Mặc định không hiển thị tên danh sách
  });

  // Thêm phương thức static để có thể sử dụng mà không cần tạo instance
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Quá hạn':
        return Colors.red;
      case 'Hôm nay':
        return const Color.fromARGB(255, 1, 115, 182);
      case 'Không có ngày':
        return Colors.white60;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Không hiển thị nếu không có công việc nào trong danh mục này
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề danh mục
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
          child: Text(
            categoryName,
            style: TextStyle(
              color: titleColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Danh sách các công việc trong danh mục này
        ...tasks.map((task) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Dismissible(
            key: Key(task.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => onTaskDelete(task.id),
            child: TaskItem(
              task: task,
              onCheckboxChanged: (_) => onTaskToggle(task),
              showListName: showListName, // Truyền thông tin hiển thị tên danh sách xuống TaskItem
            ),
          ),
        )).toList(),
      ],
    );
  }
}