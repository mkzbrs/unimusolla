import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../core/network/api_client.dart';
import '../core/storage/session_storage.dart';
import '../models/report.dart';
import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  ReportProvider(ApiClient api, this._storage) : _service = ReportService(api);

  final ReportService _service;
  final SessionStorage _storage;
  List<Report> reports = [];
  Report? selected;
  bool loading = false;
  String? error;

  Future<void> loadList() => _run(() async {
    final userId = await _requireUserId();
    reports = await _service.list(userId);
  });
  Future<void> loadDetail(int id) =>
      _run(() async => selected = await _service.detail(id));

  Future<bool> create(Map<String, dynamic> payload, List<XFile> images) async {
    final ok = await _runBool(() async {
      final userId = await _requireUserId();
      await _service.create({...payload, 'user_id': userId}, images);
    });
    if (ok) await loadList();
    return ok;
  }

  Future<bool> update(Map<String, dynamic> payload) async {
    final ok = await _runBool(() => _service.update(payload));
    if (ok) await loadList();
    return ok;
  }

  Future<bool> delete(int id) async {
    final ok = await _runBool(() => _service.delete(id));
    if (ok) await loadList();
    return ok;
  }

  Future<int> _requireUserId() async {
    final userId = await _storage.readUserId();
    if (userId == null || userId <= 0) {
      throw Exception('Missing user session. Please login again.');
    }
    return userId;
  }

  Future<void> _run(Future<void> Function() action) async {
    await _runBool(action);
  }

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
