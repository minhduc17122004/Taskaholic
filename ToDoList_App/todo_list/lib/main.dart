import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/notification_service.dart';
import 'data/lists_data.dart';
import 'firebase_options.dart';

// Xử lý tin nhắn Firebase khi ứng dụng ở chế độ nền
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  developer.log('Tin nhắn nền: ${message.messageId}', name: 'FirebaseMessaging');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cố định hướng màn hình
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Khởi tạo Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('Firebase đã được khởi tạo thành công', name: 'Firebase');
    
    // Đăng ký xử lý thông báo nền
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    developer.log('Lỗi khởi tạo Firebase: $e', name: 'Firebase', error: e);
  }
  
  // Khởi tạo dependency injection
  await di.init();
  developer.log('Dependency injection đã được khởi tạo', name: 'App');
  
  // Khởi tạo dịch vụ thông báo
  await NotificationService().init();
  
  // Khởi tạo hệ thống danh mục
  try {
    ListsData.initialize();
    await ListsData.loadCustomCategories();
    developer.log('Hệ thống danh mục đã được khởi tạo', name: 'Categories');
  } catch (e) {
    developer.log('Lỗi khởi tạo hệ thống danh mục: $e', name: 'Categories', error: e);
  }
  
  runApp(const App());
}
