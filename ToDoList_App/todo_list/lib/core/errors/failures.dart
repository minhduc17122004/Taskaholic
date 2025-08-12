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
  @override
  String toString() {
    return message;
  }
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
  @override
  String toString() {
    return message;
  }
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
  @override
  String toString() {
    return message;
  }
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
  @override
  String toString() {
    return message;
  }
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure({super.message = 'Không tìm thấy người dùng'});
  @override
  String toString() {
    return message;
  }
}

class WrongPasswordFailure extends AuthFailure {
  const WrongPasswordFailure({super.message = 'Mật khẩu không đúng'});
  @override
  String toString() {
    return message;
  }
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure({super.message = 'Email đã được sử dụng'});
  @override
  String toString() {
    return message;
  }
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure({super.message = 'Mật khẩu quá yếu'});
  @override
  String toString() {
    return message;
  }
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure({super.message = 'Email không hợp lệ'});
  @override
  String toString() {
    return message;
  }
}

class UserNotLoggedInFailure extends AuthFailure {
  const UserNotLoggedInFailure({super.message = 'Người dùng chưa đăng nhập'});
  @override
  String toString() {
    return message;
  }
}

// Task failures
class TaskFailure extends Failure {
  const TaskFailure({required super.message});
  @override
  String toString() {
    return message;
  }
}

class TaskNotFoundFailure extends TaskFailure {
  const TaskNotFoundFailure({super.message = 'Không tìm thấy công việc'});
  @override
  String toString() {
    return message;
  }
}

class InvalidTaskDataFailure extends TaskFailure {
  const InvalidTaskDataFailure({super.message = 'Dữ liệu công việc không hợp lệ'});
  @override
  String toString() {
    return message;
  }
}

// Category failures
class CategoryFailure extends Failure {
  const CategoryFailure({required super.message});
  @override
  String toString() {
    return message;
  }
}

class CategoryNotFoundFailure extends CategoryFailure {
  const CategoryNotFoundFailure({super.message = 'Không tìm thấy danh mục'});
  @override
  String toString() {
    return message;
  }
}

class DuplicateCategoryFailure extends CategoryFailure {
  const DuplicateCategoryFailure({super.message = 'Danh mục đã tồn tại'});
  @override
  String toString() {
    return message;
  }
}

class SystemCategoryFailure extends CategoryFailure {
  const SystemCategoryFailure({super.message = 'Không thể thay đổi danh mục hệ thống'});
  @override
  String toString() {
    return message;
  }
} 