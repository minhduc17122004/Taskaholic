import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmailAndPassword(String email, String password);
  Future<Either<Failure, User>> signUpWithEmailAndPassword(String email, String password);
  Future<Either<Failure, Unit>> signOut();
  Future<Either<Failure, User?>> getCurrentUser();
  Stream<User?> get user;
} 