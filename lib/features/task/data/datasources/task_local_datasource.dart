import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<List<TaskModel>> getCompletedTasks(); 
  Future<TaskModel> getTaskById(String id);
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<void> toggleTask(String id);
  Future<void> clearCompletedTasks();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String tasksKey = 'tasks';

  TaskLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final jsonList = sharedPreferences.getStringList(tasksKey) ?? [];
      final tasks = jsonList
          .map((json) => TaskModel.fromJson(jsonDecode(json)))
          .toList();
      return tasks;
    } catch (e) {
      throw Exception('Failed to get tasks from local storage');
    }
  }

  @override
  Future<List<TaskModel>> getCompletedTasks() async {
    final allTasks = await getTasks();
    return allTasks.where((task) => task.isCompleted).toList();
  }

  @override
  Future<TaskModel> getTaskById(String id) async {
    final tasks = await getTasks();
    try {
      return tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      throw Exception('Task with id $id not found');
    }
  }

  @override
  Future<void> addTask(TaskModel task) async {
    try {
      final tasks = await getTasks();
      tasks.add(task);
      await _saveTasks(tasks);
    } catch (e) {
      throw Exception('Failed to add task');
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      final tasks = await getTasks();
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = task;
        await _saveTasks(tasks);
      } else {
        throw Exception('Task not found');
      }
    } catch (e) {
      throw Exception('Failed to update task');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      final tasks = await getTasks();
      tasks.removeWhere((task) => task.id == id);
      await _saveTasks(tasks);
    } catch (e) {
      throw Exception('Failed to delete task');
    }
  }

  @override
  Future<void> toggleTask(String id) async {
    try {
      final tasks = await getTasks();
      final index = tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        final task = tasks[index];
        tasks[index] = task.copyWith(
          isCompleted: !task.isCompleted,
          completedAt: !task.isCompleted ? DateTime.now() : null,
        );
        await _saveTasks(tasks);
      } else {
        throw Exception('Task not found');
      }
    } catch (e) {
      throw Exception('Failed to toggle task');
    }
  }

  @override
  Future<void> clearCompletedTasks() async {
    try {
      final tasks = await getTasks();
      tasks.removeWhere((task) => task.isCompleted);
      await _saveTasks(tasks);
    } catch (e) {
      throw Exception('Failed to clear completed tasks');
    }
  }

  Future<void> _saveTasks(List<TaskModel> tasks) async {
    final jsonList = tasks
        .map((task) => jsonEncode(task.toJson()))
        .toList();
    await sharedPreferences.setStringList(tasksKey, jsonList);
  }
}
