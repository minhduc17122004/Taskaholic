import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../core/errors/failures.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get user;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw ServerFailure(message: 'Không thể đăng nhập, vui lòng thử lại');
      }
      return UserModel.fromFirebase(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Không tìm thấy tài khoản với email này';
          break;
        case 'wrong-password':
          message = 'Mật khẩu không đúng';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
        case 'user-disabled':
          message = 'Tài khoản đã bị vô hiệu hóa';
          break;
        default:
          message = 'Lỗi đăng nhập: ${e.message}';
      }
      throw ServerFailure(message: message);
    } catch (e) {
      throw ServerFailure(message: 'Lỗi không xác định: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(String email, String password) async {
    try {
      developer.log('Đang thử đăng ký với email: $email', name: 'FirebaseAuth');
      
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        const errorMsg = 'Không thể tạo tài khoản, vui lòng thử lại';
        developer.log('Error: $errorMsg', name: 'FirebaseAuth');
        throw ServerFailure(message: errorMsg);
      }
      
      developer.log('Đăng ký thành công với uid: ${userCredential.user!.uid}', name: 'FirebaseAuth');
      return UserModel.fromFirebase(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email đã được sử dụng bởi một tài khoản khác';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ';
          break;
        case 'operation-not-allowed':
          message = 'Đăng ký bằng email và mật khẩu không được kích hoạt';
          break;
        case 'weak-password':
          message = 'Mật khẩu quá yếu, vui lòng chọn mật khẩu mạnh hơn';
          break;
        default:
          message = 'Lỗi đăng ký: ${e.message}';
      }
      
      developer.log('FirebaseAuthException: [${e.code}] $message', name: 'FirebaseAuth');
      developer.log('Error details: ${e.toString()}', name: 'FirebaseAuth');
      
      throw ServerFailure(message: message);
    } catch (e) {
      developer.log('Unexpected error: $e', name: 'FirebaseAuth');
      throw ServerFailure(message: 'Lỗi không xác định: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }
    return UserModel.fromFirebase(user);
  }

  @override
  Stream<UserModel?> get user {
    return firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser == null ? null : UserModel.fromFirebase(firebaseUser);
    });
  }
} 