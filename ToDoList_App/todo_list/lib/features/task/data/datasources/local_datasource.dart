import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  /// Lấy danh sách tasks từ local storage
  Future<List<TaskModel>> getTasks();
  
  /// Lấy danh sách tasks đã hoàn thành từ local storage
  Future<List<TaskModel>> getCompletedTasks();
  
  /// Lưu danh sách tasks vào local storage
  Future<void> saveTasks(List<TaskModel> tasks);
  
  /// Lưu danh sách tasks đã hoàn thành vào local storage
  Future<void> saveCompletedTasks(List<TaskModel> tasks);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  TaskLocalDataSourceImpl({required this.sharedPreferences});
  
  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final jsonString = sharedPreferences.getString('tasks');
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Lỗi khi lấy tasks từ SharedPreferences: $e', name: 'TaskLocalDataSource', error: e);
      return [];
    }
  }
  
  @override
  Future<List<TaskModel>> getCompletedTasks() async {
    try {
      final jsonString = sharedPreferences.getString('completedTasks');
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      developer.log('Lỗi khi lấy completed tasks từ SharedPreferences: $e', name: 'TaskLocalDataSource', error: e);
      return [];
    }
  }
  
  @override
  Future<void> saveTasks(List<TaskModel> tasks) async {
    try {
      final jsonList = tasks.map((task) => task.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString('tasks', jsonString);
    } catch (e) {
      developer.log('Lỗi khi lưu tasks vào SharedPreferences: $e', name: 'TaskLocalDataSource', error: e);
    }
  }
  
  @override
  Future<void> saveCompletedTasks(List<TaskModel> tasks) async {
    try {
      final jsonList = tasks.map((task) => task.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await sharedPreferences.setString('completedTasks', jsonString);
    } catch (e) {
      developer.log('Lỗi khi lưu completed tasks vào SharedPreferences: $e', name: 'TaskLocalDataSource', error: e);
    }
  }
} 