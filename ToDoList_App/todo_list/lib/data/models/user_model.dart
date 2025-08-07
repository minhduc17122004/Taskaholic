import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    required super.isEmailVerified,
  });

  factory UserModel.fromFirebase(dynamic firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      isEmailVerified: firebaseUser.emailVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'isEmailVerified': isEmailVerified,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      isEmailVerified: json['isEmailVerified'],
    );
  }
} 