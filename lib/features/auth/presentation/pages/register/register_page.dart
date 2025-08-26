import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaholic/core/themes/app_color.dart';
import 'package:taskaholic/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:taskaholic/features/auth/presentation/bloc/auth_event.dart';
import 'package:taskaholic/features/auth/presentation/bloc/auth_state.dart';
import 'package:taskaholic/features/auth/presentation/pages/login/login_page.dart';
import 'package:taskaholic/features/auth/presentation/widgets/auth_header.dart';
import 'package:taskaholic/features/auth/presentation/widgets/email_input.dart';
import 'package:taskaholic/features/auth/presentation/widgets/password_input.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(ClearAuthErrorEvent());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            SignUpEvent(
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
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is Authenticated) {
            Navigator.of(context).pop();
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const AuthHeader(),
                    EmailInput(controller: _emailController),
                    const SizedBox(height: 16),
                    PasswordInput(
                      controller: _passwordController,
                      isVisible: _isPasswordVisible,
                      onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      label: 'Mật khẩu',
                    ),
                    const SizedBox(height: 16),
                    PasswordInput(
                      controller: _confirmPasswordController,
                      isVisible: _isConfirmPasswordVisible,
                      onToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      label: 'Xác nhận mật khẩu',
                      matchController: _passwordController,
                    ),
                    SizedBox(height: 36),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading ? null : _onRegisterPressed,
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
                                    'ĐĂNG KÝ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.background,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Đã có tài khoản?', style: TextStyle(color: AppColors.border)),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                            );
                          },
                          child: const Text(
                            'Đăng nhập',
                            style: TextStyle(color: AppColors.cardBackground, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
