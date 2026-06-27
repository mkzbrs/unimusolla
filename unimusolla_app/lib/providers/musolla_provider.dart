import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/musolla.dart';
import '../services/musolla_service.dart';

class MusollaProvider extends ChangeNotifier {
  MusollaProvider(ApiClient api) : _service = MusollaService(api);

  final MusollaService _service;
  List<Musolla> musollas = [];
  List<Musolla> searchResults = [];
  Musolla? selected;
  bool loading = false;
  String? error;

  Future<void> loadList() => _run(() async => musollas = await _service.list());
  Future<void> search(String query) => _run(
    () async => searchResults = query.trim().isEmpty
        ? []
        : await _service.search(query),
  );
  Future<void> loadDetail(int id) =>
      _run(() async => selected = await _service.detail(id));

  Future<void> _run(Future<void> Function() action) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } catch (exception) {
      error = exception.toString();
    }
    loading = false;
    notifyListeners();
  }
}
