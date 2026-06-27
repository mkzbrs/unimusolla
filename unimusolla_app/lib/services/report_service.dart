import 'package:image_picker/image_picker.dart';

import '../core/network/api_client.dart';
import '../models/json_helpers.dart';
import '../models/report.dart';

class ReportService {
  ReportService(this._api);
  final ApiClient _api;

  Future<List<Report>> list(int userId) async {
    final data = await _api.get(
      '/reports/list.php',
      query: {'user_id': userId},
    );
    return unwrapList(data, [
      'reports',
      'items',
      'data',
    ]).map((item) => Report.fromJson(asMap(item))).toList();
  }

  Future<Report> detail(int id) async {
    final data = await _api.get('/reports/detail.php', query: {'id': id});
    return Report.fromJson(unwrapMap(data, ['report', 'data']));
  }

  Future<int> create(Map<String, dynamic> payload, List<XFile> images) async {
    final data = asMap(await _api.post('/reports/create.php', data: payload));
    final reportId = intOf(
      data['report_id'] ??
          data['id'] ??
          unwrapMap(data, ['report', 'data'])['id'],
    );
    if (images.isNotEmpty) {
      await _api.upload(
        '/uploads/report.php',
        files: images,
        data: {'report_id': reportId},
      );
    }
    return reportId;
  }

  Future<void> update(Map<String, dynamic> payload) =>
      _api.post('/reports/update.php', data: payload);

  Future<void> delete(int id) =>
      _api.post('/reports/delete.php', data: {'report_id': id, 'id': id});
}
