import 'json_helpers.dart';

class DashboardStats {
  const DashboardStats({
    required this.usersCount,
    required this.musollasCount,
    required this.pendingReportsCount,
  });

  final int usersCount;
  final int musollasCount;
  final int pendingReportsCount;

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
    usersCount: intOf(json['users_count'] ?? json['users']),
    musollasCount: intOf(json['musollas_count'] ?? json['musollas']),
    pendingReportsCount: _countOf(
      json['pending_reports_count'] ??
          json['pending_reports'] ??
          json['pending_count'] ??
          json['reports_pending'] ??
          json['pendingReportsCount'],
    ),
  );
}

int _countOf(dynamic value) {
  if (value is List) return value.length;
  return intOf(value);
}

class AdminLog {
  const AdminLog({
    required this.id,
    required this.action,
    required this.description,
    required this.createdAt,
  });

  final int id;
  final String action;
  final String description;
  final String createdAt;

  factory AdminLog.fromJson(Map<String, dynamic> json) => AdminLog(
    id: intOf(json['id'] ?? json['log_id']),
    action: stringOf(json['action'] ?? json['type'], 'Activity'),
    description: stringOf(json['description'] ?? json['message']),
    createdAt: stringOf(json['created_at'] ?? json['date']),
  );
}
