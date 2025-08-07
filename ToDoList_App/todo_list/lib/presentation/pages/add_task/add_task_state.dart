import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class AddTaskState extends Equatable {
  const AddTaskState();

  @override
  List<Object?> get props => [];
}

class AddTaskInitial extends AddTaskState {}

class AddTaskLoading extends AddTaskState {}

class AddTaskFormState extends AddTaskState {
  final String? taskId;
  final String title;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String selectedRepeat;
  final String selectedList;
  final List<String> availableLists;
  final bool isEditing;
  final List<String> repeatOptions;

  const AddTaskFormState({
    this.taskId,
    this.title = '',
    this.selectedDate,
    this.selectedTime,
    this.selectedRepeat = 'Không lặp lại',
    required this.selectedList,
    required this.availableLists,
    this.isEditing = false,
    this.repeatOptions = const [
      'Không lặp lại',
      'Hàng ngày',
      'Hàng ngày (Thứ 2-Thứ 6)',
      'Hàng tuần',
      'Hàng tháng',
      'Hàng năm',
      'Khác...',
    ],
  });

  @override
  List<Object?> get props => [
    taskId,
    title,
    selectedDate,
    selectedTime,
    selectedRepeat,
    selectedList,
    availableLists,
    isEditing,
    repeatOptions,
  ];

  AddTaskFormState copyWith({
    String? taskId,
    String? title,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    String? selectedRepeat,
    String? selectedList,
    List<String>? availableLists,
    bool? isEditing,
    List<String>? repeatOptions,
  }) {
    return AddTaskFormState(
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedRepeat: selectedRepeat ?? this.selectedRepeat,
      selectedList: selectedList ?? this.selectedList,
      availableLists: availableLists ?? this.availableLists,
      isEditing: isEditing ?? this.isEditing,
      repeatOptions: repeatOptions ?? this.repeatOptions,
    );
  }
}

class AddTaskSuccess extends AddTaskState {
  final bool isEditing;

  const AddTaskSuccess({required this.isEditing});

  @override
  List<Object?> get props => [isEditing];
}

class AddTaskError extends AddTaskState {
  final String message;

  const AddTaskError(this.message);

  @override
  List<Object?> get props => [message];
} 