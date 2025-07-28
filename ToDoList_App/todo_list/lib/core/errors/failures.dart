import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure({required this.message});
  
  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message: message);
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure({String message = 'Không tìm thấy người dùng'}) 
      : super(message: message);
}

class WrongPasswordFailure extends AuthFailure {
  const WrongPasswordFailure({String message = 'Mật khẩu không đúng'}) 
      : super(message: message);
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure({String message = 'Email đã được sử dụng'}) 
      : super(message: message);
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure({String message = 'Mật khẩu quá yếu'}) 
      : super(message: message);
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure({String message = 'Email không hợp lệ'}) 
      : super(message: message);
}

class UserNotLoggedInFailure extends AuthFailure {
  const UserNotLoggedInFailure({String message = 'Người dùng chưa đăng nhập'}) 
      : super(message: message);
}

// Task failures
class TaskFailure extends Failure {
  const TaskFailure({required String message}) : super(message: message);
}

class TaskNotFoundFailure extends TaskFailure {
  const TaskNotFoundFailure({String message = 'Không tìm thấy công việc'}) 
      : super(message: message);
}

class InvalidTaskDataFailure extends TaskFailure {
  const InvalidTaskDataFailure({String message = 'Dữ liệu công việc không hợp lệ'}) 
      : super(message: message);
}

// Category failures
class CategoryFailure extends Failure {
  const CategoryFailure({required String message}) : super(message: message);
}

class CategoryNotFoundFailure extends CategoryFailure {
  const CategoryNotFoundFailure({String message = 'Không tìm thấy danh mục'}) 
      : super(message: message);
}

class DuplicateCategoryFailure extends CategoryFailure {
  const DuplicateCategoryFailure({String message = 'Danh mục đã tồn tại'}) 
      : super(message: message);
}

class SystemCategoryFailure extends CategoryFailure {
  const SystemCategoryFailure({String message = 'Không thể thay đổi danh mục hệ thống'}) 
      : super(message: message);
} 