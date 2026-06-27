import 'package:flutter/material.dart';

import '../models/report.dart';
import 'network_image_box.dart';
import 'status_badge.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NetworkImageBox(
                    url: report.images.isEmpty ? null : report.images.first,
                    width: 72,
                    height: 72,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          StatusBadge(status: report.status),
                          _ReportTypeBadge(report: report),
                        ],
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('View'),
                ),
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                if (onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTypeBadge extends StatelessWidget {
  const _ReportTypeBadge({required this.report});
  final Report report;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUpdate = report.isExistingMusollaUpdate;
    return Chip(
      visualDensity: VisualDensity.compact,
      side: BorderSide(
        color: isUpdate ? colorScheme.secondary : colorScheme.tertiary,
      ),
      backgroundColor: isUpdate
          ? colorScheme.secondaryContainer
          : colorScheme.tertiaryContainer,
      label: Text(
        isUpdate ? 'Update Existing Musolla' : 'New Musolla',
        style: TextStyle(
          color: isUpdate
              ? colorScheme.onSecondaryContainer
              : colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}
