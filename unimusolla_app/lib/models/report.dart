import '../core/constants/api_constants.dart';
import 'facilities.dart';
import 'json_helpers.dart';

class Report {
  const Report({
    required this.id,
    required this.name,
    required this.location,
    required this.exactLocation,
    required this.status,
    required this.available,
    required this.facilities,
    this.latitude,
    this.longitude,
    this.adminReview,
    this.musollaId,
    this.images = const [],
  });

  final int id;
  final String name;
  final String location;
  final String exactLocation;
  final String status;
  final bool available;
  final Facilities facilities;
  final double? latitude;
  final double? longitude;
  final String? adminReview;
  final int? musollaId;
  final List<String> images;

  bool get canEdit => status.toLowerCase() == 'pending';
  bool get isExistingMusollaUpdate => musollaId != null && musollaId! > 0;

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: intOf(json['id'] ?? json['report_id']),
    musollaId: nullableIntOf(json['musolla_id']),
    name: stringOf(json['name'], 'Unnamed Report'),
    location: stringOf(json['location']),
    exactLocation: stringOf(json['exact_location'] ?? json['exactLocation']),
    status: stringOf(
      json['approval_status'] ?? json['status'],
      'pending',
    ).toLowerCase(),
    available: boolOf(json['status'] ?? json['available']),
    facilities: Facilities.fromJson(json),
    latitude: doubleOf(json['latitude'] ?? json['lat']),
    longitude: doubleOf(json['longitude'] ?? json['lng']),
    adminReview: json['admin_review']?.toString() ?? json['review']?.toString(),
    images: imagePathListOf(
      json['images'] ??
          json['gallery'] ??
          json['image_path'] ??
          json['image_paths'] ??
          json['report_image_path'] ??
          json['report_images'] ??
          json['report_image_paths'] ??
          json['photos'] ??
          json['photo'] ??
          json['thumbnail'] ??
          json['report_image'] ??
          json['image_url'] ??
          json['image'] ??
          json['file_path'] ??
          json['picture'],
    ).map(ApiConstants.reportImageUrl).nonNulls.toList(),
  );
}
