import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // Khởi tạo thông báo
  Future<void> init() async {
    developer.log('Khởi tạo dịch vụ thông báo', name: 'NotificationService');
    
    // Cấu hình thông báo local
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );
    
    // Khởi tạo timezone
    tz_init.initializeTimeZones();
    
    // Cấu hình Firebase Messaging
    await _configureFirebaseMessaging();
    
    // Yêu cầu quyền thông báo
    await requestNotificationPermissions();
  }
  
  // Xử lý khi người dùng nhấn vào thông báo
  void _onSelectNotification(NotificationResponse response) {
    developer.log('Người dùng đã nhấn vào thông báo: ${response.payload}', 
        name: 'NotificationService');
    // Thêm xử lý khi người dùng nhấn vào thông báo tại đây
  }
  
  // Yêu cầu quyền thông báo
  Future<void> requestNotificationPermissions() async {
    developer.log('Yêu cầu quyền thông báo', name: 'NotificationService');
    
    // Yêu cầu quyền cho Firebase Messaging
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    developer.log(
      'Trạng thái quyền thông báo Firebase: ${settings.authorizationStatus}',
      name: 'NotificationService',
    );
    
    // Yêu cầu quyền cho Local Notifications trên iOS
    try {
      // Kiểm tra nền tảng hiện tại
      if (Platform.isIOS) {
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }
    } catch (e) {
      developer.log('Lỗi khi yêu cầu quyền thông báo iOS: $e', name: 'NotificationService', error: e);
    }
  }
  
  // Cấu hình Firebase Messaging
  Future<void> _configureFirebaseMessaging() async {
    developer.log('Cấu hình Firebase Messaging', name: 'NotificationService');
    
    // Xử lý thông báo khi ứng dụng đang chạy
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log('Nhận thông báo khi ứng dụng đang chạy: ${message.notification?.title}', 
          name: 'NotificationService');
      _showNotification(message);
    });
    
    // Xử lý thông báo khi ứng dụng đang chạy ở nền
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Xử lý thông báo khi người dùng nhấn vào thông báo để mở ứng dụng
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      developer.log('Ứng dụng được mở từ thông báo: ${message.notification?.title}', 
          name: 'NotificationService');
      // Thêm xử lý khi người dùng nhấn vào thông báo tại đây
    });
    
    // Lấy FCM token
    String? token = await _firebaseMessaging.getToken();
    developer.log('FCM Token: $token', name: 'NotificationService');
  }
  
  // Hiển thị thông báo local từ thông báo Firebase
  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    
    if (notification != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Notifications',
            channelDescription: 'Thông báo về các công việc',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data['task_id'],
      );
    }
  }
  
  // Lên lịch thông báo cho công việc
  Future<void> scheduleTaskNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    developer.log('Lên lịch thông báo cho công việc: $title vào lúc $scheduledTime', 
        name: 'NotificationService');
    
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: const AndroidNotificationDetails(
          'task_channel',
          'Task Notifications',
          channelDescription: 'Thông báo về các công việc',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }
  
  // Hủy thông báo theo ID
  Future<void> cancelNotification(int id) async {
    developer.log('Hủy thông báo có ID: $id', name: 'NotificationService');
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
  
  // Hủy tất cả thông báo
  Future<void> cancelAllNotifications() async {
    developer.log('Hủy tất cả thông báo', name: 'NotificationService');
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}

// Xử lý thông báo khi ứng dụng đang ở nền
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('Xử lý thông báo nền: ${message.notification?.title}', 
      name: 'BackgroundHandler');
  // Không thể gọi các hàm phức tạp ở đây, chỉ xử lý đơn giản
} 