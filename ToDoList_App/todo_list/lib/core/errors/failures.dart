import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure({required this.message});
  
  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure({super.message = 'Không tìm thấy người dùng'});
}

class WrongPasswordFailure extends AuthFailure {
  const WrongPasswordFailure({super.message = 'Mật khẩu không đúng'});
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure({super.message = 'Email đã được sử dụng'});
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure({super.message = 'Mật khẩu quá yếu'});
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure({super.message = 'Email không hợp lệ'});
}

class UserNotLoggedInFailure extends AuthFailure {
  const UserNotLoggedInFailure({super.message = 'Người dùng chưa đăng nhập'});
}

// Task failures
class TaskFailure extends Failure {
  const TaskFailure({required super.message});
}

class TaskNotFoundFailure extends TaskFailure {
  const TaskNotFoundFailure({super.message = 'Không tìm thấy công việc'});
}

class InvalidTaskDataFailure extends TaskFailure {
  const InvalidTaskDataFailure({super.message = 'Dữ liệu công việc không hợp lệ'});
}

// Category failures
class CategoryFailure extends Failure {
  const CategoryFailure({required super.message});
}

class CategoryNotFoundFailure extends CategoryFailure {
  const CategoryNotFoundFailure({super.message = 'Không tìm thấy danh mục'});
}

class DuplicateCategoryFailure extends CategoryFailure {
  const DuplicateCategoryFailure({super.message = 'Danh mục đã tồn tại'});
}

class SystemCategoryFailure extends CategoryFailure {
  const SystemCategoryFailure({super.message = 'Không thể thay đổi danh mục hệ thống'});
} 