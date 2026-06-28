class ApiConstants {
  static const baseUrl = 'https://unimusolla-api.mkzbrs.com';
  static const baseImageUrl = '$baseUrl/uploads';

  static String? profileImageUrl(String? filename) =>
      _uploadUrl(filename, 'profiles');

  static String? musollaImageUrl(String? filename) =>
      _uploadUrl(filename, 'musollas');

  static String? reportImageUrl(String? filename) =>
      _uploadUrl(filename, 'reports');

  static String? _uploadUrl(String? value, String folder) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

    final normalized = raw
        .replaceFirst(RegExp(r'^/+'), '')
        .replaceFirst(RegExp(r'^(api/)?'), '')
        .replaceFirst(RegExp(r'^(public/)?'), '');

    if (normalized.startsWith('uploads/')) {
      return '$baseUrl/$normalized';
    }

    final filename = normalized.replaceFirst(
      RegExp(r'^(profiles|profile|musollas|musolla|reports|report)/'),
      '',
    );
    return '$baseImageUrl/$folder/$filename';
  }
}
