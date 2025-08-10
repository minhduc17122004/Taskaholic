import 'package:flutter/material.dart';
import '../domain/entities/task.dart';
import '../screens/add_task_screen.dart';

class TaskItem extends StatelessWidget {
  final Task task; // Công việc cần hiển thị
  final Function(bool?)
  onCheckboxChanged; // Hàm xử lý khi người dùng chọn/bỏ chọn công việc
  final bool showListName; // Cờ xác định có hiển thị tên danh sách hay không
  final bool showDateTime; // Cờ xác định có hiển thị thời gian hay không
  final bool
  showOriginalList; // Cờ xác định có hiển thị danh sách gốc hay không

  const TaskItem({
    super.key,
    required this.task,
    required this.onCheckboxChanged,
    this.showListName = false, // Mặc định là không hiển thị tên danh sách
    this.showDateTime = true, // Mặc định là hiển thị thời gian
    this.showOriginalList = false, // Mặc định là không hiển thị danh sách gốc
  });

  @override
  Widget build(BuildContext context) {
    // Xác định xem có hiển thị danh sách gốc hay không
    final bool shouldShowOriginalList = showOriginalList;

    // Xác định có hiển thị thông tin ngày giờ không
    final shouldShowDateTime = showDateTime &&
        task.hasTime ||
        showOriginalList;

    // Xác định có hiển thị tên danh sách không
    final shouldShowListName = showListName &&
        task.list.isNotEmpty;

    return InkWell(
      // Thêm InkWell để xử lý sự kiện nhấp vào
      onTap: () {
        // Khi người dùng nhấp vào task, mở màn hình chỉnh sửa task
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddTaskScreen(existingTask: task),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 75, 123),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ô checkbox căn giữa theo chiều dọc
              Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: task.isCompleted,
                    onChanged: onCheckboxChanged,
                    fillColor: WidgetStateProperty .all(Colors.transparent),
                    checkColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Chi tiết công việc căn giữa theo chiều dọc
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề công việc
                    Text(
                      task.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 2,
                      ),
                    ),
                    // Chỉ hiển thị phần thông tin bổ sung nếu có thông tin để hiển thị
                    if (showDateTime ||
                        shouldShowOriginalList ||
                        showListName ||
                        task.repeat != 'Không lặp lại') ...[
                      const SizedBox(height: 3),
                      // Thông tin thời gian và danh sách của công việc
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Chỉ hiển thị ngày giờ nếu showDateTime = true và task có thời gian
                          if (showDateTime && task.hasTime)
                            Text(
                              '${task.getFormattedDate()}, ${task.getFormattedTime(context)}',
                              style: TextStyle(
                                color:
                                    task.category == 'Quá hạn'
                                        ? Colors.red.shade300
                                        : Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          // Chỉ hiển thị ngày nếu không có thời gian
                          if (showDateTime && !task.hasTime && task.getFormattedDate().isNotEmpty)
                            Text(
                              task.getFormattedDate(),
                              style: TextStyle(
                                color:
                                    task.category == 'Quá hạn'
                                        ? Colors.red.shade300
                                        : Colors.white70,
                                fontSize: 14,
                              ),
                            ),

                          // Hiển thị tên danh sách gốc nếu đang ở trong danh sách "Kết thúc"
                          if (shouldShowOriginalList)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(
                                    alpha: 0.15,
                                  ), // độ mờ của màu nền
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  task.originalList,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),

                          // Hiển thị tên danh sách nếu showListName là true
                          if (showListName &&
                              task.list != 'Kết thúc')
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  task.list,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),

                          // Hiển thị biểu tượng lặp lại nếu công việc được thiết lập lặp lại
                          if (task.repeat != 'Không lặp lại')
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Icon(
                                Icons.repeat,
                                color: Colors.white70,
                                size: 14,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
