import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaholic/core/themes/app_color.dart';
import 'package:taskaholic/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:taskaholic/features/auth/presentation/bloc/auth_event.dart';
import 'package:taskaholic/features/auth/presentation/bloc/auth_state.dart';
import 'package:taskaholic/features/auth/presentation/pages/register/register_page.dart';
import 'package:taskaholic/features/auth/presentation/widgets/auth_header.dart';
import 'package:taskaholic/features/auth/presentation/widgets/password_input.dart';
import 'package:taskaholic/features/home/presentation/pages/home_page.dart';
import 'package:taskaholic/features/auth/presentation/widgets/email_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(ClearAuthErrorEvent());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginButtonPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            SignInEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (state is AuthError) {

            _passwordController.clear();
          } 
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AuthHeader(),
                        EmailInput(
                          controller: _emailController,
                        ),
                        const SizedBox(height: 16),
                        PasswordInput(
                          controller: _passwordController,
                          isVisible: _isPasswordVisible,
                          onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          label: 'Mật khẩu',
                        ),
                        const SizedBox(height: 16),
                        if (state is AuthError)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.message,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: state is AuthError ? 20 : 36),
                        // Login button
                        ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : _onLoginButtonPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.inputBackgroundDark,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: AppColors.inputBackgroundDark.withValues(alpha: 0.5),
                          ),
                          child: state is AuthLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.background,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'ĐĂNG NHẬP',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.background,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),
                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Chưa có tài khoản?',
                              style: TextStyle(color: AppColors.textPrimaryDark),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Đăng ký ngay',
                                style: TextStyle(
                                  color: AppColors.cardBackground,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 