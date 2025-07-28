import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final bool isEmailVerified;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    required this.isEmailVerified,
  });

  @override
  List<Object?> get props => [id, email, displayName, isEmailVerified];
} 