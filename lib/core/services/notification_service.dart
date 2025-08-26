import 'dart:developer' as developer;
import 'package:taskaholic/features/task/domain/entities/task_entity.dart';

/// Interface for notification service
abstract class NotificationService {
  /// Schedule a notification for a task
  Future<void> scheduleTaskNotification({
    required String taskId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  });

  /// Cancel a notification by task ID
  Future<void> cancelTaskNotification(String taskId);

  /// Cancel all notifications
  Future<void> cancelAllNotifications();

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled();

  /// Request notification permissions
  Future<bool> requestPermissions();
}

/// Implementation of notification service
class NotificationServiceImpl implements NotificationService {
  static const String _logName = 'NotificationService';

  /// Chuyển đổi task ID thành notification ID hợp lệ (32-bit integer)
  int _getNotificationId(String taskId) {
    // Tạo hash code từ task ID và đảm bảo nó nằm trong phạm vi 32-bit integer
    int hash = taskId.hashCode;
    // Đảm bảo giá trị dương và trong phạm vi 32-bit
    return hash.abs() % 2147483647; // 2^31 - 1
  }

  @override
  Future<void> scheduleTaskNotification({
    required String taskId,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      // Chỉ lên lịch thông báo nếu thời gian trong tương lai
      if (!scheduledDate.isAfter(DateTime.now())) {
        developer.log(
          'Không lên lịch thông báo cho thời gian đã qua: $scheduledDate',
          name: _logName,
        );
        return;
      }

      final notificationId = _getNotificationId(taskId);
      
      developer.log(
        'Lên lịch thông báo ID: $notificationId cho task: $taskId vào lúc $scheduledDate',
        name: _logName,
      );

      // TODO: Implement với flutter_local_notifications hoặc firebase_messaging
      // await _localNotifications.schedule(
      //   notificationId,
      //   title,
      //   body,
      //   scheduledDate,
      //   payload: taskId,
      // );
      
      developer.log('Đã lên lịch thông báo thành công', name: _logName);
    } catch (e) {
      developer.log(
        'Lỗi khi lên lịch thông báo cho task $taskId: $e',
        name: _logName,
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> cancelTaskNotification(String taskId) async {
    try {
      final notificationId = _getNotificationId(taskId);
      
      developer.log(
        'Hủy thông báo ID: $notificationId cho task: $taskId',
        name: _logName,
      );

      // TODO: Implement với flutter_local_notifications
      // await _localNotifications.cancel(notificationId);
      
      developer.log('Đã hủy thông báo thành công', name: _logName);
    } catch (e) {
      developer.log(
        'Lỗi khi hủy thông báo cho task $taskId: $e',
        name: _logName,
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    try {
      developer.log('Hủy tất cả thông báo', name: _logName);

      // TODO: Implement với flutter_local_notifications
      // await _localNotifications.cancelAll();
      
      developer.log('Đã hủy tất cả thông báo thành công', name: _logName);
    } catch (e) {
      developer.log('Lỗi khi hủy tất cả thông báo: $e', name: _logName, error: e);
      rethrow;
    }
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    try {
      // TODO: Implement check permissions
      // final settings = await _localNotifications.getNotificationAppLaunchDetails();
      // return settings?.didNotificationLaunchApp ?? false;
      
      developer.log('Checking notification permissions...', name: _logName);
      return true; // Mock return for now
    } catch (e) {
      developer.log('Lỗi khi kiểm tra quyền thông báo: $e', name: _logName, error: e);
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      developer.log('Yêu cầu quyền thông báo...', name: _logName);

      // TODO: Implement với flutter_local_notifications
      // final result = await _localNotifications.requestPermissions();
      // return result ?? false;
      
      developer.log('Đã cấp quyền thông báo', name: _logName);
      return true; // Mock return for now
    } catch (e) {
      developer.log('Lỗi khi yêu cầu quyền thông báo: $e', name: _logName, error: e);
      return false;
    }
  }
}

/// Extension methods for TaskEntity notification helpers
extension TaskNotificationExtension on TaskEntity {
  /// Check if task can have notifications
  bool get canHaveNotification {
    return date != null && 
           time != null && 
           hasTime && 
           !isCompleted;
  }

  /// Get notification DateTime for the task
  DateTime? get notificationDateTime {
    if (!canHaveNotification) return null;
    
    return DateTime(
      date!.year,
      date!.month,
      date!.day,
      time!.hour,
      time!.minute,
    );
  }

  /// Get notification title
  String get notificationTitle => 'Nhắc nhở: $title';

  /// Get notification body
  String get notificationBody {
    final dateStr = getFormattedDate();
    final timeStr = getFormattedTime();
    return 'Đến hạn: $dateStr lúc $timeStr';
  }
}
