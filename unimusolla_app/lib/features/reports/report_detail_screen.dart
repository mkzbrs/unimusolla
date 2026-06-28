import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/report.dart';
import '../../providers/report_provider.dart';
import '../../widgets/app_states.dart';
import '../../widgets/network_image_box.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key, required this.id});
  final int id;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  static const _primary = Color(0xFF004532);
  static const _secondary = Color(0xFF006C4A);
  static const _onSurface = Color(0xFF121C2A);
  static const _onSurfaceVariant = Color(0xFF3F4944);
  static const _surface = Color(0xFFF8F9FF);
  static const _surfaceLowest = Color(0xFFFFFFFF);
  static const _surfaceVariant = Color(0xFFD9E3F6);
  static const _secondaryContainer = Color(0xFF82F5C1);
  static const _errorContainer = Color(0xFFFFDAD6);
  static const _onErrorContainer = Color(0xFF93000A);
  static const _tertiaryContainer = Color(0xFF365A4A);
  static const _onTertiaryContainer = Color(0xFFA8D0BC);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ReportProvider>().loadDetail(widget.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();
    final report = provider.selected;
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Report Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: _onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: _surface.withValues(alpha: .92),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _surfaceVariant),
        ),
      ),
      body: Builder(
        builder: (_) {
          if (provider.loading && report == null) {
            return const SkeletonList(itemCount: 3);
          }
          if (provider.error != null && report == null) {
            return ErrorState(
              message: provider.error!,
              onRetry: () => provider.loadDetail(widget.id),
            );
          }
          if (report == null) {
            return const EmptyState(
              icon: Icons.assignment_late_outlined,
              title: 'Not found',
              message: 'This report could not be loaded.',
            );
          }
          for (final imageUrl in report.images) {
            debugPrint('REPORT IMAGE URL: $imageUrl');
          }
          return RefreshIndicator(
            onRefresh: () => provider.loadDetail(widget.id),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              children: [
                Center(child: _StatusPill(status: report.status)),
                const SizedBox(height: 24),
                _ReportSummaryCard(report: report),
                const SizedBox(height: 24),
                Text(
                  'Changes Submitted',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _ChangesCard(report: report),
                const SizedBox(height: 20),
                Text(
                  'Attached Photos',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: _onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                _PhotoGrid(images: report.images),
                const SizedBox(height: 24),
                _ActionButtons(report: report),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final rejected = normalized == 'rejected';
    final approved = normalized == 'approved';
    final icon = rejected
        ? Icons.cancel_outlined
        : approved
        ? Icons.check_circle
        : Icons.info;
    final background = rejected
        ? _ReportDetailScreenState._errorContainer
        : approved
        ? _ReportDetailScreenState._tertiaryContainer
        : _ReportDetailScreenState._secondaryContainer;
    final foreground = rejected
        ? _ReportDetailScreenState._onErrorContainer
        : approved
        ? _ReportDetailScreenState._onTertiaryContainer
        : _ReportDetailScreenState._secondary;
    final label = normalized == 'pending' ? 'Under Review' : status;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: foreground, size: 20),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w900,
                letterSpacing: .7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportSummaryCard extends StatelessWidget {
  const _ReportSummaryCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: NetworkImageBox(
                url: report.images.isEmpty ? null : report.images.first,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _ReportDetailScreenState._primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                _IconText(
                  icon: Icons.location_on_outlined,
                  text: report.exactLocation.isEmpty
                      ? report.location
                      : report.exactLocation,
                ),
                const SizedBox(height: 6),
                _IconText(
                  icon: Icons.assignment_outlined,
                  text: 'Report #${report.id} • ${_reportType(report)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangesCard extends StatelessWidget {
  const _ChangesCard({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final facilities = report.facilities.labels.join(', ');
    return DecoratedBox(
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailField(label: 'Musolla Name', value: report.name),
            _DetailField(
              label: 'Location',
              value: [
                report.location,
                report.exactLocation,
              ].where((value) => value.trim().isNotEmpty).join(' - '),
            ),
            _DetailField(
              label: 'Amenities',
              value: facilities.isEmpty ? 'Facilities not listed' : facilities,
            ),
            _DetailField(
              label: 'Admin Review Status',
              value: report.adminReview?.trim().isNotEmpty == true
                  ? report.adminReview!.trim()
                  : report.status,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return DecoratedBox(
        decoration: _cardDecoration(),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: _IconText(
            icon: Icons.image_not_supported_outlined,
            text: 'No photos attached',
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            border: Border.all(color: _ReportDetailScreenState._surfaceVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: NetworkImageBox(
            url: images[index],
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Support contact coming soon.')),
            ),
            icon: const Icon(Icons.support_agent),
            label: const Text('Contact Support'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _ReportDetailScreenState._secondary,
              side: const BorderSide(
                color: _ReportDetailScreenState._secondary,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: report.canEdit
                ? () => context.push('/reports/${report.id}/edit')
                : null,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Update Information'),
            style: FilledButton.styleFrom(
              backgroundColor: _ReportDetailScreenState._surfaceVariant,
              foregroundColor: _ReportDetailScreenState._onSurfaceVariant,
              disabledBackgroundColor: _ReportDetailScreenState._surfaceVariant,
              disabledForegroundColor: _ReportDetailScreenState
                  ._onSurfaceVariant
                  .withValues(alpha: .55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _ReportDetailScreenState._secondary,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.trim().isEmpty ? '-' : value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _ReportDetailScreenState._onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 16,
            color: _ReportDetailScreenState._onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.trim().isEmpty ? '-' : text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _ReportDetailScreenState._onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: _ReportDetailScreenState._surfaceLowest,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: _ReportDetailScreenState._surfaceVariant),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .05),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

String _reportType(Report report) {
  return report.isExistingMusollaUpdate
      ? 'Update Existing Musolla'
      : 'New Musolla';
}
