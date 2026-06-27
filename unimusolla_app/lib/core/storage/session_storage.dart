import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user.dart';

class SessionStorage {
  static const tokenKey = 'token';
  static const userIdKey = 'user_id';
  static const usernameKey = 'username';
  static const emailKey = 'email';
  static const roleKey = 'role';
  static const profileImageKey = 'profile_image';

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<User?> readUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(userIdKey);
    final username = prefs.getString(usernameKey);
    final email = prefs.getString(emailKey);
    final role = prefs.getString(roleKey);
    if (id == null || username == null || email == null || role == null) {
      return null;
    }
    return User(
      id: id,
      username: username,
      email: email,
      role: role,
      profileImage: prefs.getString(profileImageKey),
    );
  }

  Future<String?> readRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(roleKey);
  }

  Future<int?> readUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(userIdKey);
  }

  Future<void> saveSession(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await _writeUser(prefs, user);
  }

  Future<void> updateUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await _writeUser(prefs, user);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userIdKey);
    await prefs.remove(usernameKey);
    await prefs.remove(emailKey);
    await prefs.remove(roleKey);
    await prefs.remove(profileImageKey);
  }

  Future<void> _writeUser(SharedPreferences prefs, User user) async {
    await prefs.setInt(userIdKey, user.id);
    await prefs.setString(usernameKey, user.username);
    await prefs.setString(emailKey, user.email);
    await prefs.setString(roleKey, user.role);
    final profileImage = user.profileImage;
    if (profileImage == null || profileImage.isEmpty) {
      await prefs.remove(profileImageKey);
    } else {
      await prefs.setString(profileImageKey, profileImage);
    }
  }
}
