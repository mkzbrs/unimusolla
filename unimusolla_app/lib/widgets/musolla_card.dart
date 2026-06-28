import 'package:flutter/material.dart';

import '../models/musolla.dart';
import 'network_image_box.dart';

class MusollaCard extends StatelessWidget {
  const MusollaCard({super.key, required this.musolla, required this.onTap});
  final Musolla musolla;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: .12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: const Color(0xFFBEC9C2).withValues(alpha: .45)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkImageBox(url: musolla.imageUrl),
                  if (!musolla.available)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .22),
                      ),
                    ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _AvailabilityBadge(available: musolla.available),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    musolla.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF121C2A),
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _LocationLine(text: musolla.location),
                  if (musolla.exactLocation.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _LocationLine(text: musolla.exactLocation, maxLines: 2),
                  ],
                  const SizedBox(height: 10),
                  Divider(
                    height: 1,
                    color: const Color(0xFFBEC9C2).withValues(alpha: .45),
                  ),
                  const SizedBox(height: 10),
                  _FacilityIcons(musolla: musolla),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({required this.text, this.maxLines = 1});

  final String text;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.location_on_outlined,
            size: 16,
            color: Color(0xFF3F4944),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF3F4944)),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.available});
  final bool available;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: available ? const Color(0xFF365A4A) : const Color(0xFFFFDAD6),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .14),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              available ? Icons.circle : Icons.cleaning_services_outlined,
              size: available ? 8 : 14,
              color: available
                  ? const Color(0xFF82F5C1)
                  : const Color(0xFF93000A),
            ),
            const SizedBox(width: 5),
            Text(
              available ? 'Available' : 'Unavailable',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: available
                    ? const Color(0xFFA8D0BC)
                    : const Color(0xFF93000A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FacilityIcons extends StatelessWidget {
  const _FacilityIcons({required this.musolla});
  final Musolla musolla;

  @override
  Widget build(BuildContext context) {
    final facilities = [
      if (musolla.facilities.wudhu) (Icons.water_drop_outlined, 'Wudhu Area'),
      if (musolla.facilities.toilet) (Icons.wc_outlined, 'Toilet'),
      if (musolla.facilities.aircond)
        (Icons.ac_unit_outlined, 'Air Conditioning'),
      if (musolla.facilities.prayerMats) (Icons.layers_outlined, 'Prayer Mats'),
      if (musolla.facilities.telekung) (Icons.checkroom_outlined, 'Telekung'),
    ];

    if (facilities.isEmpty) {
      return Text(
        'Facilities not listed',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6F7973)),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final facility in facilities.take(5))
          Tooltip(
            message: facility.$2,
            child: Icon(facility.$1, size: 17, color: const Color(0xFF3F4944)),
          ),
      ],
    );
  }
}
