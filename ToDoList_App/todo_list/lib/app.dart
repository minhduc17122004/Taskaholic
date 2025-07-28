import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'features/auth/presentation/pages/login/login_page.dart';
import 'presentation/bloc/task/task_bloc.dart';
import 'presentation/bloc/task/task_event.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/home/home_bloc.dart';
import 'presentation/pages/home/home_event.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Cố định hướng màn hình là dọc
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<TaskBloc>(
          create: (context) => di.sl<TaskBloc>()..add(const LoadTasks()),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => di.sl<HomeBloc>()..add(const LoadHomeDataEvent()),
        ),
        // TODO: Add other BlocProviders here
      ],
      child: MaterialApp(
        title: 'Todo List',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is Authenticated) {
              return const HomePage();
            } else {
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
} 