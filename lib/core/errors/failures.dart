import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure({this.message = ''});
  
  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure({super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message});
}

// Auth-specific failures
class AuthFailure extends Failure {
  const AuthFailure({super.message});
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({super.message});
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure({super.message});
}

// Category-specific failures
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Không có quyền truy cập'});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Không tìm thấy dữ liệu'});
}

class DuplicateFailure extends Failure {
  const DuplicateFailure({super.message = 'Dữ liệu đã tồn tại'});
}

class SystemResourceFailure extends Failure {
  const SystemResourceFailure({super.message = 'Không thể thao tác với tài nguyên hệ thống'});
}
