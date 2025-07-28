import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ListsData {
  static final List<String> lists = [
    'Danh sách tất cả',
    'Công việc',
    'Mặc định',
  ];
  
  // Thêm lại biến listOptions để tương thích với code cũ
  static final List<String> listOptions = [
    'Danh sách tất cả',
    'Công việc',
    'Mặc định',
  ];
  
  // Phương thức lấy danh sách cho màn hình thêm task
  static List<String> getAddTaskListOptions() {
    // Loại bỏ "Danh sách tất cả" vì không thể thêm task vào danh sách này
    return listOptions.where((list) => 
      list != 'Danh sách tất cả').toList();
  }
}
