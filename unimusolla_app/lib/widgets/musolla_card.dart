import 'package:flutter/material.dart';

import '../models/musolla.dart';
import 'network_image_box.dart';
import 'status_badge.dart';

class MusollaCard extends StatelessWidget {
  const MusollaCard({super.key, required this.musolla, required this.onTap});
  final Musolla musolla;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: NetworkImageBox(
                  url: musolla.imageUrl,
                  width: 88,
                  height: 88,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      musolla.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      musolla.location,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        StatusBadge(
                          status: musolla.available
                              ? 'available'
                              : 'unavailable',
                        ),
                        ...musolla.facilities.labels
                            .take(2)
                            .map(
                              (label) => Chip(
                                label: Text(label),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
