import '../core/network/api_client.dart';
import '../models/admin_models.dart';
import '../models/json_helpers.dart';
import '../models/musolla.dart';
import '../models/report.dart';
import '../models/user.dart';

class AdminService {
  AdminService(this._api);
  final ApiClient _api;

  Future<DashboardStats> dashboard() async => DashboardStats.fromJson(
    unwrapMap(await _api.get('/admin/dashboard.php'), ['data']),
  );

  Future<List<Report>> pending() => reports(status: 'pending');

  Future<List<Report>> reports({String status = 'pending'}) async {
    final data = await _api.get(
      '/admin/reports.php',
      query: {'status': status},
    );
    return unwrapList(data, [
      'reports',
      'items',
      'data',
    ]).map((item) => Report.fromJson(asMap(item))).toList();
  }

  Future<Report> reportDetail(int id) async {
    final data = await _api.get('/admin/report_detail.php', query: {'id': id});
    return Report.fromJson(unwrapMap(data, ['report', 'data']));
  }

  Future<void> approve(int adminId, int reportId) => _api.post(
    '/admin/approve.php',
    data: {'admin_id': adminId, 'report_id': reportId},
  );
  Future<void> reject(int adminId, int reportId) => _api.post(
    '/admin/reject.php',
    data: {'admin_id': adminId, 'report_id': reportId},
  );

  Future<List<User>> users() async {
    final data = await _api.get('/admin/users.php');
    return unwrapList(data, [
      'users',
      'items',
      'data',
    ]).map((item) => User.fromJson(asMap(item))).toList();
  }

  Future<User> userDetail(int id) async => User.fromJson(
    unwrapMap(await _api.get('/admin/user_detail.php', query: {'id': id}), [
      'user',
      'data',
    ]),
  );
  Future<void> updateUser({
    required int id,
    required String username,
    required String email,
    required String role,
  }) => _api.post(
    '/admin/update_user.php',
    data: {'id': id, 'username': username, 'email': email, 'role': role},
  );
  Future<void> deleteUser(int id) =>
      _api.post('/admin/delete_user.php', data: {'id': id});

  Future<List<Musolla>> musollas() async {
    final data = await _api.get('/musollas/list.php');
    return unwrapList(data, [
      'musollas',
      'items',
      'data',
    ]).map((item) => Musolla.fromJson(asMap(item))).toList();
  }

  Future<void> deleteMusolla(int id) =>
      _api.post('/admin/delete_musolla.php', data: {'id': id});

  Future<List<AdminLog>> logs() async {
    final data = await _api.get('/admin/logs.php');
    return unwrapList(data, [
      'logs',
      'items',
      'data',
    ]).map((item) => AdminLog.fromJson(asMap(item))).toList();
  }
}
