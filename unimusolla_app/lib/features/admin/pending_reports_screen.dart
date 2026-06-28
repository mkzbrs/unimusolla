import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/report.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/app_states.dart';
import '../../widgets/network_image_box.dart';

class PendingReportsScreen extends StatefulWidget {
  const PendingReportsScreen({super.key});

  @override
  State<PendingReportsScreen> createState() => _PendingReportsScreenState();
}

class _PendingReportsScreenState extends State<PendingReportsScreen> {
  static const _surface = Color(0xFFF8F9FF);
  static const _surfaceContainerLow = Color(0xFFEFF4FF);
  static const _onSurface = Color(0xFF121C2A);
  static const _onSurfaceVariant = Color(0xFF3F4944);
  static const _outline = Color(0xFF6F7973);
  static const _outlineVariant = Color(0xFFBEC9C2);
  static const _primary = Color(0xFF004532);
  static const _onSecondaryContainer = Color(0xFF00714E);
  static const _pendingBackground = Color(0xFFFEF3C7);
  static const _pendingForeground = Color(0xFF92400E);
  static const _error = Color(0xFFBA1A1A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AdminProvider>().loadPending(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final pendingReports = provider.pendingReports
        .where((report) => report.status.toLowerCase() == 'pending')
        .toList();

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        surfaceTintColor: _surface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: .12),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/admin'),
          icon: const Icon(Icons.arrow_back),
          color: _primary,
        ),
        title: const Text(
          'Pending Reports',
          style: TextStyle(color: _primary, fontWeight: FontWeight.w900),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadPending,
        child: Builder(
          builder: (_) {
            if (provider.loading && pendingReports.isEmpty) {
              return const SkeletonList();
            }
            if (provider.error != null && pendingReports.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: 480,
                    child: ErrorState(
                      message: provider.error!,
                      onRetry: provider.loadPending,
                    ),
                  ),
                ],
              );
            }
            if (pendingReports.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 24),
                children: const [
                  EmptyState(
                    icon: Icons.fact_check_outlined,
                    title: 'No pending reports',
                    message: 'Everything looks quiet right now.',
                  ),
                ],
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 672),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  itemCount: pendingReports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final report = pendingReports[index];
                    return _PendingReportCard(
                      report: report,
                      onView: () => context.push('/reports/${report.id}'),
                      onApprove: () => _approve(report.id),
                      onReject: () => _reject(report.id),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _approve(int id) async {
    if (!await confirmAction(
      context,
      'Approve report?',
      'This will add the musolla for users to view.',
    )) {
      return;
    }
    final ok = await context.read<AdminProvider>().approve(id);
    if (mounted && ok) showAppMessage(context, 'Report approved');
  }

  Future<void> _reject(int id) async {
    if (!await confirmAction(
      context,
      'Reject report?',
      'This report will be marked as rejected.',
    )) {
      return;
    }
    final ok = await context.read<AdminProvider>().reject(id);
    if (mounted && ok) showAppMessage(context, 'Report rejected');
  }
}

class _PendingReportCard extends StatelessWidget {
  const _PendingReportCard({
    required this.report,
    required this.onView,
    required this.onApprove,
    required this.onReject,
  });

  final Report report;
  final VoidCallback onView;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: _PendingReportsScreenState._outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
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
                          url: report.images.isEmpty
                              ? null
                              : report.images.first,
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
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: _PendingReportsScreenState
                                              ._onSurface,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const _PendingPill(),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              report.isExistingMusollaUpdate
                                  ? 'Facility Update'
                                  : 'New Musolla',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: _PendingReportsScreenState
                                        ._onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.place_outlined,
                                  size: 14,
                                  color: _PendingReportsScreenState._outline,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    report.location.isEmpty
                                        ? report.exactLocation
                                        : report.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: _PendingReportsScreenState
                                              ._outline,
                                        ),
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
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: _PendingReportsScreenState._surfaceContainerLow,
                    border: Border(
                      top: BorderSide(
                        color: _PendingReportsScreenState._outlineVariant,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Update: Under Review',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  _PendingReportsScreenState._onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Reject',
                          visualDensity: VisualDensity.compact,
                          onPressed: onReject,
                          icon: const Icon(Icons.cancel_outlined),
                          color: _PendingReportsScreenState._error,
                        ),
                        IconButton(
                          tooltip: 'Approve',
                          visualDensity: VisualDensity.compact,
                          onPressed: onApprove,
                          icon: const Icon(Icons.check_circle_outline),
                          color:
                              _PendingReportsScreenState._onSecondaryContainer,
                        ),
                        TextButton.icon(
                          onPressed: onView,
                          iconAlignment: IconAlignment.end,
                          label: const Text('View Details'),
                          icon: const Icon(Icons.chevron_right, size: 16),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                _PendingReportsScreenState._primary,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingPill extends StatelessWidget {
  const _PendingPill();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _PendingReportsScreenState._pendingBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          'PENDING',
          style: TextStyle(
            color: _PendingReportsScreenState._pendingForeground,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: .6,
          ),
        ),
      ),
    );
  }
}
