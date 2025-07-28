class ServerException implements Exception {
  final String message;
  
  ServerException({this.message = 'Lỗi máy chủ'});
}

class CacheException implements Exception {
  final String message;
  
  CacheException({this.message = 'Lỗi bộ nhớ đệm'});
}

class NetworkException implements Exception {
  final String message;
  
  NetworkException({this.message = 'Lỗi kết nối mạng'});
}

// Authentication exceptions
class AuthException implements Exception {
  final String message;
  
  AuthException({this.message = 'Lỗi xác thực'});
}

class UserNotFoundException implements AuthException {
  @override
  final String message;
  
  UserNotFoundException({this.message = 'Không tìm thấy người dùng'});
}

class WrongPasswordException implements AuthException {
  @override
  final String message;
  
  WrongPasswordException({this.message = 'Mật khẩu không đúng'});
}

class EmailAlreadyInUseException implements AuthException {
  @override
  final String message;
  
  EmailAlreadyInUseException({this.message = 'Email đã được sử dụng'});
}

class WeakPasswordException implements AuthException {
  @override
  final String message;
  
  WeakPasswordException({this.message = 'Mật khẩu quá yếu'});
}

class InvalidEmailException implements AuthException {
  @override
  final String message;
  
  InvalidEmailException({this.message = 'Email không hợp lệ'});
}

class UserNotLoggedInException implements AuthException {
  @override
  final String message;
  
  UserNotLoggedInException({this.message = 'Người dùng chưa đăng nhập'});
}

// Task exceptions
class TaskException implements Exception {
  final String message;
  
  TaskException({this.message = 'Lỗi công việc'});
}

class TaskNotFoundException implements TaskException {
  @override
  final String message;
  
  TaskNotFoundException({this.message = 'Không tìm thấy công việc'});
}

class InvalidTaskDataException implements TaskException {
  @override
  final String message;
  
  InvalidTaskDataException({this.message = 'Dữ liệu công việc không hợp lệ'});
}

// Category exceptions
class CategoryException implements Exception {
  final String message;
  
  CategoryException({this.message = 'Lỗi danh mục'});
}

class CategoryNotFoundException implements CategoryException {
  @override
  final String message;
  
  CategoryNotFoundException({this.message = 'Không tìm thấy danh mục'});
}

class DuplicateCategoryException implements CategoryException {
  @override
  final String message;
  
  DuplicateCategoryException({this.message = 'Danh mục đã tồn tại'});
}

class SystemCategoryException implements CategoryException {
  @override
  final String message;
  
  SystemCategoryException({this.message = 'Không thể thay đổi danh mục hệ thống'});
} 