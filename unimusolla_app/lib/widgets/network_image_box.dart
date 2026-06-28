import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImageBox extends StatelessWidget {
  const NetworkImageBox({
    super.key,
    required this.url,
    this.width,
    this.height,
  });
  final String? url;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.mosque,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: Colors.grey.shade200),
      errorWidget: (_, imageUrl, error) {
        debugPrint('IMAGE ERROR: $imageUrl');
        debugPrint(error.toString());
        return Container(
          width: width,
          height: height,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        );
      },
    );
  }
}
