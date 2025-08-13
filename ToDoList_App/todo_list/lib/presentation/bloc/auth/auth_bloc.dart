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
import '../../../core/di/injection_container.dart' as di;
import '../../../data/datasources/local/task_local_datasource.dart';
import '../../../data/datasources/local/category_local_datasource.dart';
import '../../../data/lists_data.dart';

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
    on<ClearAuthErrorEvent>(_onClearAuthError);
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    // Clear any stale local caches before signing in
    try {
      final taskLocal = di.sl<TaskLocalDataSource>();
      await taskLocal.clearAllTaskCaches();
      final categoryLocal = di.sl<CategoryLocalDataSource>();
      await categoryLocal.clearCategories();
      await ListsData.resetCategoriesForAuthChange();
      developer.log('Cleared local caches (tasks & categories) before sign in', name: 'AuthBloc');
    } catch (e) {
      developer.log('Failed to clear local cache before sign in: $e', name: 'AuthBloc');
    }

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

    // Clear any stale local caches before sign up
    try {
      final taskLocal = di.sl<TaskLocalDataSource>();
      await taskLocal.clearAllTaskCaches();
      final categoryLocal = di.sl<CategoryLocalDataSource>();
      await categoryLocal.clearCategories();
      await ListsData.resetCategoriesForAuthChange();
      developer.log('Cleared local caches (tasks & categories) before sign up', name: 'AuthBloc');
    } catch (e) {
      developer.log('Failed to clear local cache before sign up: $e', name: 'AuthBloc');
    }
    
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

    // Clear local caches on sign out
    try {
      final taskLocal = di.sl<TaskLocalDataSource>();
      await taskLocal.clearAllTaskCaches();
      final categoryLocal = di.sl<CategoryLocalDataSource>();
      await categoryLocal.clearCategories();
      await ListsData.resetCategoriesForAuthChange();
      developer.log('Cleared local caches (tasks & categories) on sign out', name: 'AuthBloc');
    } catch (e) {
      developer.log('Failed to clear local cache on sign out: $e', name: 'AuthBloc');
    }

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

  void _onClearAuthError(ClearAuthErrorEvent event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
} 