import 'package:flutter/material.dart';

import '../models/report.dart';
import 'network_image_box.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    required this.onView,
    this.onEdit,
    this.onDelete,
    this.trailing,
  });

  final Report report;
  final VoidCallback onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: .12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBEC9C2)),
      ),
      child: InkWell(
        onTap: onView,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageBox(
                      url: report.images.isEmpty ? null : report.images.first,
                      width: 64,
                      height: 64,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                report.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: const Color(0xFF121C2A),
                                      fontWeight: FontWeight.w800,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusPill(status: report.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          report.isExistingMusollaUpdate
                              ? 'Update Existing Musolla'
                              : 'New Musolla',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFF3F4944)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              size: 14,
                              color: Color(0xFF6F7973),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                report.location.isEmpty
                                    ? report.exactLocation
                                    : report.location,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: const Color(0xFF6F7973)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xFFEFF4FF),
                border: Border(top: BorderSide(color: Color(0xFFBEC9C2))),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _footerText,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF3F4944),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onDelete != null && report.canEdit)
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        color: const Color(0xFFBA1A1A),
                        visualDensity: VisualDensity.compact,
                      ),
                    if (onEdit != null)
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        color: const Color(0xFF004532),
                        visualDensity: VisualDensity.compact,
                      ),
                    TextButton.icon(
                      onPressed: onView,
                      iconAlignment: IconAlignment.end,
                      label: const Text('View Details'),
                      icon: const Icon(Icons.chevron_right, size: 18),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF004532),
                        textStyle: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _footerText {
    final review = report.adminReview?.trim();
    if (review != null && review.isNotEmpty) return 'Update: $review';
    return switch (report.status.toLowerCase()) {
      'pending' => 'Update: Under Review',
      'approved' => 'Update: Approved by admin',
      'rejected' => 'Update: Rejected by admin',
      _ => 'Update: ${report.status}',
    };
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final (background, foreground) = switch (normalized) {
      'approved' => (const Color(0xFFC3ECD7), const Color(0xFF294E3F)),
      'rejected' => (const Color(0xFFFFDAD6), const Color(0xFF93000A)),
      _ => (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          normalized.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: foreground,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: .5,
          ),
        ),
      ),
    );
  }
}
