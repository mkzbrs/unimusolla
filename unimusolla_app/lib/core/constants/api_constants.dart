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

    final filename = raw
        .replaceFirst(RegExp(r'^/+'), '')
        .replaceFirst(RegExp(r'^(uploads/)?(profiles|musollas|reports)/'), '');
    return '$baseImageUrl/$folder/$filename';
  }
}
