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
    final response = asMap(
      await _api.post('/reports/create.php', data: payload),
    );

    final body = unwrapMap(response, ['data']);
    final reportId = intOf(body['report_id'] ?? body['id']);

    if (reportId <= 0) {
      throw Exception('Backend did not return a valid report_id');
    }

    if (images.isNotEmpty) {
      await _uploadReportImages(reportId, images);
    }

    return reportId;
  }

  Future<void> update(Map<String, dynamic> payload, List<XFile> images) async {
    await _api.post('/reports/update.php', data: payload);
    final reportId = intOf(payload['report_id'] ?? payload['id']);
    if (images.isNotEmpty && reportId > 0) {
      await _uploadReportImages(reportId, images);
    }
  }

  Future<void> delete(int id) =>
      _api.post('/reports/delete.php', data: {'report_id': id, 'id': id});

  Future<void> _uploadReportImages(int reportId, List<XFile> images) async {
    final data = {'report_id': reportId, 'id': reportId};

    final response = await _api.upload(
      '/uploads/report.php',
      files: images,
      field: 'images',
      data: data,
    );

    if (_uploadSucceeded(response)) return;

    final fallback = await _api.upload(
      '/uploads/report.php',
      files: images,
      field: 'image',
      arrayField: false,
      data: data,
    );

    if (!_uploadSucceeded(fallback)) {
      final message = stringOf(
        asMap(fallback)['message'] ?? asMap(response)['message'],
        'Image upload failed. Please try again.',
      );
      throw Exception(message);
    }
  }

  bool _uploadSucceeded(dynamic response) {
    final body = asMap(response);
    if (body.isEmpty) return true;
    if (body['success'] == false) return false;
    final successText = body['success']?.toString().toLowerCase();
    return successText != 'false' && successText != '0';
  }
}
