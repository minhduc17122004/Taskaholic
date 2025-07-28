import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/get_current_user.dart';
import '../../../domain/usecases/sign_in_with_email_and_password.dart';
import '../../../domain/usecases/sign_out.dart';
import '../../../domain/usecases/sign_up_with_email_and_password.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmailAndPassword signInWithEmailAndPassword;
  final SignUpWithEmailAndPassword signUpWithEmailAndPassword;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({
    required this.signInWithEmailAndPassword,
    required this.signUpWithEmailAndPassword,
    required this.signOut,
    required this.getCurrentUser,
  }) : super(AuthInitial()) {
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<SignOutEvent>(_onSignOut);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signInWithEmailAndPassword(
      SignInParams(
        email: event.email,
        password: event.password,
      ),
    );
    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (user) async => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    developer.log('Bắt đầu đăng ký với email: ${event.email}', name: 'AuthBloc');
    emit(AuthLoading());
    
    final result = await signUpWithEmailAndPassword(
      SignUpParams(
        email: event.email,
        password: event.password,
      ),
    );
    
    await result.fold(
      (failure) async {
        developer.log('Đăng ký thất bại: ${failure.message}', name: 'AuthBloc');
        emit(AuthError(failure.message));
      },
      (user) async {
        developer.log('Đăng ký thành công với userId: ${user.id}', name: 'AuthBloc');
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signOut();
    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (_) async => emit(Unauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await getCurrentUser();
    await result.fold(
      (failure) async => emit(Unauthenticated()),
      (user) async {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
} 