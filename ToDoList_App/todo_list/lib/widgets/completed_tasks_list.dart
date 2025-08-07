import 'package:flutter/material.dart';
import '../domain/entities/task.dart';

class CompletedTasksList extends StatelessWidget {
  final Map<String, List<Task>> tasksByList;
  final Function(Task) buildTaskItem;

  const CompletedTasksList({
    super.key,
    required this.tasksByList,
    required this.buildTaskItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hiển thị các task đã hoàn thành theo danh mục
        ...tasksByList.entries.map((entry) {
          final listName = entry.key;
          final tasksInList = entry.value;
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 1, 63, 113).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            listName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${tasksInList.length} công việc',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ...tasksInList.map((task) => buildTaskItem(task)),
                const SizedBox(height: 8),
              ],
            ),
          );
        }),
      ],
    );
  }
} 