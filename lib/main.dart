import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskaholic/core/di/di.dart' as di;
import 'package:taskaholic/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Set preferred orientations once at app startup
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Initialize Firebase
    await Firebase.initializeApp();
    developer.log('Firebase initialized successfully', name: 'Main');
    
    // Initialize dependency injection
    await di.init();
    developer.log('Dependency injection initialized successfully', name: 'Main');
    
    runApp(const App());
  } catch (e, stackTrace) {
    developer.log(
      'Error during app initialization: $e',
      name: 'Main',
      error: e,
      stackTrace: stackTrace,
    );
    
    // Run app with error handling
    runApp(const ErrorApp());
  }
}

/// Error app to show when initialization fails
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taskaholic - Error',
      home: Scaffold(
        backgroundColor: Colors.red.shade900,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'App Initialization Failed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please restart the app',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
