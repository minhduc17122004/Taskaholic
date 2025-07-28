import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/entities/task.dart';
import '../presentation/bloc/task/task_bloc.dart';
import '../presentation/bloc/task/task_event.dart';
import '../screens/add_task_screen.dart';

class TaskSearchDelegate extends SearchDelegate<Task?> {
  final List<Task> tasks;
  final List<Task> completedTasks;

  TaskSearchDelegate(this.tasks, this.completedTasks);

  @override
  String get searchFieldLabel => 'Tìm kiếm công việc...';

  @override
  TextStyle get searchFieldStyle => const TextStyle(
        color: Colors.white,
        fontSize: 16,
      );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 1, 115, 182),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
      ),
      scaffoldBackgroundColor: const Color.fromARGB(255, 0, 45, 81),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nhập từ khóa để tìm kiếm',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    final lowercaseQuery = query.toLowerCase();
    final matchingTasks = tasks.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery);
    }).toList();
    
    final matchingCompletedTasks = completedTasks.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery);
    }).toList();

    if (matchingTasks.isEmpty && matchingCompletedTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy công việc nào',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Tạo công việc mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 1, 115, 182),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTaskScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return Container(
      color: const Color.fromARGB(255, 0, 45, 81),
      child: ListView(
        children: [
          if (matchingTasks.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Text(
                'Công việc đang thực hiện',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...matchingTasks.map((task) => _buildTaskItem(context, task)),
          ],
          if (matchingCompletedTasks.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Text(
                'Công việc đã hoàn thành',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...matchingCompletedTasks.map((task) => _buildTaskItem(context, task)),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 1, 80, 143).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            color: Colors.white,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: Colors.white54,
          ),
        ),
        subtitle: task.hasTime || task.list != 'Mặc định'
            ? Text(
                '${task.list != 'Mặc định' ? task.getFormattedDate() : ''}'
                '${task.list != 'Mặc định' && task.hasTime ? ' • ' : ''}'
                '${task.hasTime ? task.getFormattedTime(context) : ''}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              )
            : null,
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            context.read<TaskBloc>().add(ToggleTaskEvent(task.id));
            close(context, task);
          },
          activeColor: const Color.fromARGB(255, 1, 115, 182),
          checkColor: Colors.white,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(existingTask: task),
            ),
          );
          close(context, task);
        },
      ),
    );
  }
} 