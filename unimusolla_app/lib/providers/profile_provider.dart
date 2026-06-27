import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../core/network/api_client.dart';
import '../core/storage/session_storage.dart';
import '../models/user.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(ApiClient api, this._storage)
    : _service = ProfileService(api);

  final ProfileService _service;
  final SessionStorage _storage;
  User? profile;
  bool loading = false;
  String? error;

  Future<void> loadProfile() => _run(() async {
    final userId = await _requireUserId();
    profile = await _service.me(userId);
  });

  Future<User?> updateProfile(String username, XFile? image) async {
    User? next;
    final ok = await _runBool(() async {
      final userId = await _requireUserId();
      next = await _service.update(userId, username, image);
    });
    return ok ? next : null;
  }

  Future<int> _requireUserId() async {
    final userId = await _storage.readUserId();
    if (userId == null || userId <= 0) {
      throw Exception('Missing user session. Please login again.');
    }
    return userId;
  }

  Future<void> _run(Future<void> Function() action) async => _runBool(action);

  Future<bool> _runBool(Future<void> Function() action) async {
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
