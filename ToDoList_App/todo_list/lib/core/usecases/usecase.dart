import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Interface cho tất cả các UseCase trong ứng dụng.
/// Type [T] là kiểu dữ liệu trả về từ UseCase.
/// Type [Params] là kiểu dữ liệu tham số đầu vào cho UseCase.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Class này được sử dụng khi UseCase không cần tham số đầu vào.
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
} 