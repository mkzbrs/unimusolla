import '../core/constants/api_constants.dart';
import 'json_helpers.dart';

class User {
  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.profileImage,
  });

  final int id;
  final String username;
  final String email;
  final String role;
  final String? profileImage;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: intOf(json['id'] ?? json['user_id']),
    username: stringOf(json['username'] ?? json['name'], 'User'),
    email: stringOf(json['email']),
    role: stringOf(json['role'], 'user').toLowerCase(),
    profileImage: ApiConstants.profileImageUrl(
      json['profile_image']?.toString() ??
          json['image']?.toString() ??
          json['avatar']?.toString(),
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'role': role,
    'profile_image': profileImage,
  };
}
