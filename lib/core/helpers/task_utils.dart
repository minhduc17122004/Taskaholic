import 'package:taskaholic/features/task/domain/entities/task_entity.dart';

({List<TaskEntity> completed, List<TaskEntity> pending}) splitTasks(List<TaskEntity> all) {
  final completed = all.where((e) => e.isCompleted).toList();
  final pending = all.where((e) => !e.isCompleted).toList();
  return (completed: completed, pending: pending);
}
