import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/storage/session_storage.dart';
import '../models/admin_models.dart';
import '../models/musolla.dart';
import '../models/report.dart';
import '../models/user.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider(ApiClient api, this._storage) : _service = AdminService(api);

  final AdminService _service;
  final SessionStorage _storage;
  DashboardStats? stats;
  List<Report> pendingReports = [];
  List<User> users = [];
  List<Musolla> musollas = [];
  List<AdminLog> logs = [];
  bool loading = false;
  String? error;

  Future<void> loadDashboard() =>
      _run(() async => stats = await _service.dashboard());
  Future<void> loadPending() =>
      _run(() async => pendingReports = await _service.pending());
  Future<void> loadUsers() => _run(() async => users = await _service.users());
  Future<void> loadMusollas() =>
      _run(() async => musollas = await _service.musollas());
  Future<void> loadLogs() => _run(() async => logs = await _service.logs());

  Future<bool> approve(int id) async {
    final ok = await _runBool(() async {
      final adminId = await _requireAdminId();
      await _service.approve(adminId, id);
    });
    if (ok) await loadPending();
    return ok;
  }

  Future<bool> reject(int id) async {
    final ok = await _runBool(() async {
      final adminId = await _requireAdminId();
      await _service.reject(adminId, id);
    });
    if (ok) await loadPending();
    return ok;
  }

  Future<bool> deleteUser(int id) async {
    final ok = await _runBool(() => _service.deleteUser(id));
    if (ok) await loadUsers();
    return ok;
  }

  Future<bool> deleteMusolla(int id) async {
    final ok = await _runBool(() => _service.deleteMusolla(id));
    if (ok) await loadMusollas();
    return ok;
  }

  Future<int> _requireAdminId() async {
    final adminId = await _storage.readUserId();
    if (adminId == null || adminId <= 0) {
      throw Exception('Missing admin session. Please login again.');
    }
    return adminId;
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
