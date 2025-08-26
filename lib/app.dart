import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaholic/core/themes/index.dart';
import 'package:taskaholic/core/routes/app_routes.dart';
import 'package:taskaholic/core/di/di.dart' as di;
import 'package:taskaholic/features/task/presentation/bloc/task_bloc.dart';
import 'package:taskaholic/features/task/presentation/bloc/task_event.dart';
import 'package:taskaholic/features/home/presentation/pages/home_page.dart';

// Auth feature - Now implemented
import 'package:taskaholic/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:taskaholic/features/auth/presentation/bloc/auth_event.dart';

// TODO: Uncomment when these features are implemented
// import 'package:taskaholic/features/home/presentation/bloc/home_bloc.dart';
// import 'package:taskaholic/features/home/presentation/bloc/home_event.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Task BLoC - Currently implemented
        BlocProvider<TaskBloc>(
          create: (context) => di.sl<TaskBloc>()..add(const LoadTasksEvent()),
        ),
        
        // Auth BLoC - Now implemented
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        
        // TODO: Uncomment when these features are implemented
        // BlocProvider<HomeBloc>(
        //   create: (context) => di.sl<HomeBloc>()..add(const LoadHomeDataEvent()),
        // ),
        // BlocProvider<CategoryBloc>(
        //   create: (context) => di.sl<CategoryBloc>()..add(const LoadCategoriesEvent()),
        // ),
      ],
      child: MaterialApp(
        title: 'Taskaholic',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Using dark theme as per the existing UI colors
        
        // Route configuration
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRoutes.home, // TODO: Change to AppRouter.getInitialRoute() when auth is implemented
        
        // TODO: Replace with proper auth flow when AuthBloc is implemented
        home: const HomePage(),
        
        // TODO: Uncomment when AuthBloc is implemented
        // home: BlocBuilder<AuthBloc, AuthState>(
        //   builder: (context, state) {
        //     if (state is AuthLoading) {
        //       return const Scaffold(
        //         body: Center(
        //           child: CircularProgressIndicator(),
        //         ),
        //       );
        //     } else if (state is Authenticated) {
        //       return const HomePage();
        //     } else {
        //       return const LoginPage();
        //     }
        //   },
        // ),
      ),
    );
  }
} 