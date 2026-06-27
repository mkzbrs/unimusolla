import '../core/network/api_client.dart';
import '../models/json_helpers.dart';
import '../models/user.dart';

class LoginResult {
  const LoginResult({required this.token, required this.user});
  final String token;
  final User user;
}

class AuthService {
  AuthService(this._api);
  final ApiClient _api;

  Future<LoginResult> login(String email, String password) async {
    final data = asMap(
      await _api.postJson(
        '/auth/login.php',
        data: {'email': email, 'password': password},
      ),
    );
    return LoginResult(
      token: stringOf(data['token']),
      user: User.fromJson(unwrapMap(data, ['user'])),
    );
  }

  Future<void> register(String username, String email, String password) async {
    await _api.postJson(
      '/auth/register.php',
      data: {'username': username, 'email': email, 'password': password},
    );
  }

  Future<void> logout() async {}
}
