import 'package:flutter/material.dart';
import 'package:taskaholic/features/home/presentation/pages/home_page.dart';
import 'package:taskaholic/features/task/presentation/pages/task_form_page.dart';
import 'package:taskaholic/features/task/domain/entities/task_entity.dart';

// TODO: Uncomment when these features are implemented
// import 'package:taskaholic/features/auth/presentation/pages/login/login_page.dart';
// import 'package:taskaholic/features/home/presentation/pages/completed_page.dart';

/// App route names
class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String completed = '/completed';
  static const String taskForm = '/task-form';
  static const String taskEdit = '/task-edit';
  // TODO: Add more routes as features are implemented  
  // static const String settings = '/settings';
  // static const String categories = '/categories';
}

/// App route configuration
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // TODO: Uncomment when LoginPage is implemented
      // case AppRoutes.login:
      //   return MaterialPageRoute(
      //     builder: (_) => const LoginPage(),
      //     settings: settings,
      //   );
        
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
        
      case AppRoutes.taskForm:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TaskFormPage(
            initialCategory: args?['initialCategory'] as String?,
          ),
          settings: settings,
        );
        
      case AppRoutes.taskEdit:
        final task = settings.arguments as TaskEntity;
        return MaterialPageRoute(
          builder: (_) => TaskFormPage(
            taskToEdit: task,
          ),
          settings: settings,
        );
        
      // TODO: Uncomment when CompletedPage is implemented
      // case AppRoutes.completed:
      //   return MaterialPageRoute(
      //     builder: (_) => const CompletedPage(),
      //     settings: settings,
      //   );
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(
              child: Text(
                'Route not found',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          settings: settings,
        );
    }
  }
  
  /// Get initial route based on authentication status
  static String getInitialRoute() {
    // TODO: Check authentication status from shared preferences or secure storage
    // For now, always start with home (until auth is implemented)
    return AppRoutes.home;
  }
}
