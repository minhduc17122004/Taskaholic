import 'dart:convert';
import 'package:flutter/material.dart';
import 'lib/data/models/task_model.dart';
import 'lib/features/task/data/models/task_model.dart' as feature;

void main() {
  print('Testing TaskModel.fromJson fix...\n');
  
  // Test data with time as Map (object format)
  final jsonWithTimeObject = {
    'id': 'test1',
    'title': 'Test Task 1',
    'date': '2024-01-15T10:00:00.000Z',
    'time': {'hour': 14, 'minute': 30},
    'repeat': 'Không lặp lại',
    'list': 'Công việc',
    'originalList': 'Công việc',
    'isCompleted': false,
  };
  
  // Test data with time as String
  final jsonWithTimeString = {
    'id': 'test2',
    'title': 'Test Task 2',
    'date': '2024-01-15T10:00:00.000Z',
    'time': '16:45',
    'repeat': 'Hàng ngày',
    'list': 'Cá nhân',
    'originalList': 'Cá nhân',
    'isCompleted': true,
  };
  
  // Test data with invalid time format
  final jsonWithInvalidTime = {
    'id': 'test3',
    'title': 'Test Task 3',
    'date': '2024-01-15T10:00:00.000Z',
    'time': 12345, // Invalid format
    'repeat': 'Hàng tuần',
    'list': 'Học tập',
    'isCompleted': false,
  };

  try {
    print('1. Testing legacy TaskModel with object time format...');
    final task1 = TaskModel.fromJson(jsonWithTimeObject);
    print('✅ Success: ${task1.title} at ${task1.time.hour}:${task1.time.minute}');
    
    print('\n2. Testing legacy TaskModel with string time format...');
    final task2 = TaskModel.fromJson(jsonWithTimeString);
    print('✅ Success: ${task2.title} at ${task2.time.hour}:${task2.time.minute}');
    
    print('\n3. Testing legacy TaskModel with invalid time format...');
    final task3 = TaskModel.fromJson(jsonWithInvalidTime);
    print('✅ Success (fallback): ${task3.title} at ${task3.time.hour}:${task3.time.minute}');
    
    print('\n4. Testing feature TaskModel with object time format...');
    final featureTask1 = feature.TaskModel.fromJson(jsonWithTimeObject);
    print('✅ Success: ${featureTask1.title} at ${featureTask1.time.hour}:${featureTask1.time.minute}');
    
    print('\n5. Testing feature TaskModel with string time format...');
    final featureTask2 = feature.TaskModel.fromJson(jsonWithTimeString);
    print('✅ Success: ${featureTask2.title} at ${featureTask2.time.hour}:${featureTask2.time.minute}');
    
    print('\n🎉 All tests passed! The type casting bug has been fixed.');
    
  } catch (e) {
    print('❌ Error during testing: $e');
  }
} 