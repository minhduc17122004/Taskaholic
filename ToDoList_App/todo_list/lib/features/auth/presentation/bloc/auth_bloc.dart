import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_email_and_password.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email_and_password.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmailAndPassword signInWithEmailAndPassword;
  final SignUpWithEmailAndPassword signUpWithEmailAndPassword;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;

  AuthBloc({
    required this.signInWithEmailAndPassword,
    required this.signUpWithEmailAndPassword,
    required this.signOut,
    required this.getCurrentUser,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final result = await getCurrentUser(NoParams());
      
      result.fold(
        (failure) {
          developer.log('Lỗi khi kiểm tra trạng thái xác thực: ${failure.message}', name: 'AuthBloc');
          emit(Unauthenticated());
        },
        (user) {
          if (user != null) {
            emit(Authenticated(user));
          } else {
            emit(Unauthenticated());
          }
        },
      );
    } catch (e) {
      developer.log('Lỗi không xác định khi kiểm tra trạng thái xác thực: $e', name: 'AuthBloc');
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignIn(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final result = await signInWithEmailAndPassword(
        SignInParams(
          email: event.email,
          password: event.password,
        ),
      );
      
      result.fold(
        (failure) {
          developer.log('Lỗi khi đăng nhập: ${failure.message}', name: 'AuthBloc');
          emit(AuthError(failure.message));
        },
        (user) {
          emit(Authenticated(user));
        },
      );
    } catch (e) {
      developer.log('Lỗi không xác định khi đăng nhập: $e', name: 'AuthBloc');
      emit(AuthError('Đã xảy ra lỗi không xác định khi đăng nhập'));
    }
  }

  Future<void> _onSignUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final result = await signUpWithEmailAndPassword(
        SignUpParams(
          email: event.email,
          password: event.password,
        ),
      );
      
      result.fold(
        (failure) {
          developer.log('Lỗi khi đăng ký: ${failure.message}', name: 'AuthBloc');
          emit(AuthError(failure.message));
        },
        (user) {
          emit(Authenticated(user));
        },
      );
    } catch (e) {
      developer.log('Lỗi không xác định khi đăng ký: $e', name: 'AuthBloc');
      emit(AuthError('Đã xảy ra lỗi không xác định khi đăng ký'));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final result = await signOut(NoParams());
      
      result.fold(
        (failure) {
          developer.log('Lỗi khi đăng xuất: ${failure.message}', name: 'AuthBloc');
          emit(AuthError(failure.message));
        },
        (_) {
          emit(Unauthenticated());
        },
      );
    } catch (e) {
      developer.log('Lỗi không xác định khi đăng xuất: $e', name: 'AuthBloc');
      emit(AuthError('Đã xảy ra lỗi không xác định khi đăng xuất'));
    }
  }
} 