import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<List<TaskModel>> getCompletedTasks();
  Future<void> cacheTasks(List<TaskModel> tasks);
  Future<void> cacheCompletedTasks(List<TaskModel> tasks);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final SharedPreferences sharedPreferences;

  TaskLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<TaskModel>> getTasks() async {
    final jsonString = sharedPreferences.getString('tasks');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => TaskModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<List<TaskModel>> getCompletedTasks() async {
    final jsonString = sharedPreferences.getString('completedTasks');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => TaskModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    final jsonString = json.encode(tasks.map((e) => e.toJson()).toList());
    await sharedPreferences.setString('tasks', jsonString);
  }

  @override
  Future<void> cacheCompletedTasks(List<TaskModel> tasks) async {
    final jsonString = json.encode(tasks.map((e) => e.toJson()).toList());
    await sharedPreferences.setString('completedTasks', jsonString);
  }
} 