import '../core/constants/api_constants.dart';
import 'facilities.dart';
import 'json_helpers.dart';

class Musolla {
  const Musolla({
    required this.id,
    required this.name,
    required this.location,
    required this.exactLocation,
    required this.available,
    required this.facilities,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.images = const [],
  });

  final int id;
  final String name;
  final String location;
  final String exactLocation;
  final bool available;
  final Facilities facilities;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final List<String> images;

  factory Musolla.fromJson(Map<String, dynamic> json) {
    final images = imagePathListOf(
      json['images'] ??
          json['gallery'] ??
          json['image_paths'] ??
          json['musolla_images'] ??
          json['musolla_image_paths'] ??
          json['photos'] ??
          json['photo'] ??
          json['image_path'] ??
          json['report_images'] ??
          json['report_image_paths'],
    ).map(ApiConstants.musollaImageUrl).nonNulls.toList();
    final singleImage = ApiConstants.musollaImageUrl(
      json['thumbnail']?.toString() ??
          json['cover_photo']?.toString() ??
          json['image_path']?.toString() ??
          json['file_path']?.toString() ??
          json['musolla_image']?.toString() ??
          json['musolla_image_path']?.toString() ??
          json['cover_image']?.toString() ??
          json['report_image']?.toString() ??
          json['report_image_path']?.toString() ??
          json['photo']?.toString() ??
          json['image']?.toString() ??
          json['image_url']?.toString() ??
          json['picture']?.toString(),
    );
    return Musolla(
      id: intOf(json['id'] ?? json['musolla_id']),
      name: stringOf(json['name'], 'Unnamed Musolla'),
      location: stringOf(json['location']),
      exactLocation: stringOf(json['exact_location'] ?? json['exactLocation']),
      available: boolOf(json['available'] ?? json['status']),
      facilities: Facilities.fromJson(json),
      latitude: doubleOf(json['latitude'] ?? json['lat']),
      longitude: doubleOf(json['longitude'] ?? json['lng']),
      imageUrl: singleImage ?? (images.isNotEmpty ? images.first : null),
      images: images.isEmpty && singleImage != null ? [singleImage] : images,
    );
  }
}
