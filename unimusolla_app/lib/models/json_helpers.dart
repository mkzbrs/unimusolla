Map<String, dynamic> asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

Map<String, dynamic> unwrapMap(dynamic data, List<String> keys) {
  final root = asMap(data);
  for (final key in keys) {
    final nested = root[key];
    if (nested is Map) return asMap(nested);
  }
  return root;
}

List<dynamic> unwrapList(dynamic data, List<String> keys) {
  if (data is List) return data;
  final root = asMap(data);
  for (final key in keys) {
    final nested = root[key];
    if (nested is List) return nested;
    if (nested is Map) {
      final inside = unwrapList(nested, keys);
      if (inside.isNotEmpty) return inside;
    }
  }
  return const [];
}

int intOf(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
int? nullableIntOf(dynamic value) => int.tryParse(value?.toString() ?? '');
double? doubleOf(dynamic value) => double.tryParse(value?.toString() ?? '');
String stringOf(dynamic value, [String fallback = '']) =>
    value?.toString() ?? fallback;

bool boolOf(dynamic value) {
  if (value is bool) return value;
  final text = value?.toString().toLowerCase();
  return text == '1' || text == 'true' || text == 'yes' || text == 'available';
}

List<String> stringListOf(dynamic value) {
  if (value is List)
    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();
  final text = value?.toString();
  if (text == null || text.isEmpty) return const [];
  return text
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

List<String> imagePathListOf(dynamic value) {
  if (value is List) {
    return value
        .map((item) {
          if (item is Map) {
            final map = asMap(item);
            return stringOf(
              map['image_path'] ??
                  map['report_image'] ??
                  map['report_image_path'] ??
                  map['musolla_image'] ??
                  map['musolla_image_path'] ??
                  map['thumbnail'] ??
                  map['filename'] ??
                  map['file_name'] ??
                  map['file_path'] ??
                  map['url'] ??
                  map['image'] ??
                  map['image_url'] ??
                  map['photo'] ??
                  map['picture'] ??
                  map['path'],
            ).trim();
          }
          return item.toString().trim();
        })
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return stringListOf(value);
}
