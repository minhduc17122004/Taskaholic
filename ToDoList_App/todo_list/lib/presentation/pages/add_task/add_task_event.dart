import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/task.dart';

abstract class AddTaskEvent extends Equatable {
  const AddTaskEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAddTaskEvent extends AddTaskEvent {
  final Task? existingTask;
  final String? initialList;

  const InitializeAddTaskEvent({this.existingTask, this.initialList});

  @override
  List<Object?> get props => [existingTask, initialList];
}

class ChangeDateEvent extends AddTaskEvent {
  final DateTime date;

  const ChangeDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class ChangeTimeEvent extends AddTaskEvent {
  final TimeOfDay time;

  const ChangeTimeEvent(this.time);

  @override
  List<Object?> get props => [time];
}

class ChangeRepeatEvent extends AddTaskEvent {
  final String repeat;

  const ChangeRepeatEvent(this.repeat);

  @override
  List<Object?> get props => [repeat];
}

class ChangeListEvent extends AddTaskEvent {
  final String list;

  const ChangeListEvent(this.list);

  @override
  List<Object?> get props => [list];
}

class SaveTaskEvent extends AddTaskEvent {
  final String title;
  final bool isEditing;

  const SaveTaskEvent({
    required this.title,
    required this.isEditing,
  });

  @override
  List<Object?> get props => [title, isEditing];
}

class DeleteTaskEvent extends AddTaskEvent {
  const DeleteTaskEvent();
} 