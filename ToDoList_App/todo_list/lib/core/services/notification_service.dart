import 'dart:developer' as developer;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      // Khởi tạo timezone
      tz_data.initializeTimeZones();
      
      // Khởi tạo Android settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // Khởi tạo iOS settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );
      
      // Khởi tạo settings cho tất cả nền tảng
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      
      // Khởi tạo plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          developer.log('Notification clicked: ${response.payload}', name: 'NotificationService');
        },
      );
      
      developer.log('Notification service initialized', name: 'NotificationService');
    } catch (e) {
      developer.log('Error initializing notification service: $e', name: 'NotificationService', error: e);
    }
  }

  Future<void> scheduleTaskNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      // Android notification details
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'task_channel',
        'Task Reminders',
        channelDescription: 'Notifications for task reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );
      
      // iOS notification details
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      // Notification details
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );
      
      // Lên lịch thông báo với fallback strategy
      await _scheduleNotificationSafely(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        platformChannelSpecifics: platformChannelSpecifics,
        payload: payload,
      );
      
      developer.log(
        'Scheduled notification for task $id at ${scheduledDate.toString()}',
        name: 'NotificationService',
      );
    } catch (e) {
      developer.log(
        'Error scheduling notification: $e',
        name: 'NotificationService',
        error: e,
      );
    }
  }

  // Hàm helper để lên lịch thông báo an toàn với fallback
  Future<void> _scheduleNotificationSafely({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationDetails platformChannelSpecifics,
    String? payload,
  }) async {
    try {
      // Thử sử dụng inexactAllowWhileIdle trước (an toàn hơn)
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
      
      developer.log(
        'Successfully scheduled notification with inexact timing',
        name: 'NotificationService',
      );
    } catch (e) {
      // Nếu vẫn lỗi, thử với alarmClock làm fallback
      try {
        developer.log(
          'Inexact scheduling failed, trying alarmClock: $e',
          name: 'NotificationService',
        );
        
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledDate, tz.local),
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          payload: payload,
        );
        
        developer.log(
          'Successfully scheduled notification with alarmClock',
          name: 'NotificationService',
        );
      } catch (e2) {
        // Nếu tất cả đều thất bại, log lỗi nhưng không crash app
        developer.log(
          'All notification scheduling methods failed: $e2',
          name: 'NotificationService',
          error: e2,
        );
        
        // Có thể thêm logic để hiển thị thông báo cho user
        throw Exception('Không thể lên lịch thông báo. Vui lòng kiểm tra quyền ứng dụng.');
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    developer.log('Cancelled notification with id: $id', name: 'NotificationService');
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    developer.log('Cancelled all notifications', name: 'NotificationService');
  }
} 