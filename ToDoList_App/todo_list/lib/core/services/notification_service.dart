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
      
      // Lên lịch thông báo
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    developer.log('Cancelled notification with id: $id', name: 'NotificationService');
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    developer.log('Cancelled all notifications', name: 'NotificationService');
  }
} 