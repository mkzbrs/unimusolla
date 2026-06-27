import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/storage/session_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(ApiClient api, this._storage) : _service = AuthService(api);

  final AuthService _service;
  final SessionStorage _storage;

  User? user;
  bool loading = false;
  String? error;

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.role == 'admin';

  Future<void> restoreSession() async {
    final token = await _storage.readToken();
    if (token == null) return;
    user = await _storage.readUser();
  }

  Future<bool> login(String email, String password) async {
    return _run(() async {
      final result = await _service.login(email, password);
      if (result.token.isEmpty) {
        throw Exception(
          'Login succeeded, but the API response did not include a supported token field.',
        );
      }
      user = result.user;
      await _storage.saveSession(result.token, result.user);
    });
  }

  Future<bool> register(String username, String email, String password) =>
      _run(() => _service.register(username, email, password));

  Future<void> logout() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _service.logout();
    } catch (e) {
      // Log the error, but proceed with local logout to ensure the session is
      // cleared on the client regardless of server-side success.
      if (kDebugMode) {
        print('API logout failed: $e');
      }
    } finally {
      await _storage.clear();
      user = null;
      loading = false;
      notifyListeners();
    }
  }

  Future<void> setUser(User nextUser) async {
    user = nextUser;
    await _storage.updateUser(nextUser);
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await action();
      loading = false;
      notifyListeners();
      return true;
    } catch (exception) {
      error = exception.toString();
      loading = false;
      notifyListeners();
      return false;
    }
  }
}
