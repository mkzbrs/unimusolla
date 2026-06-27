import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../widgets/app_states.dart';
import '../../widgets/report_card.dart';

class PendingReportsScreen extends StatefulWidget {
  const PendingReportsScreen({super.key});

  @override
  State<PendingReportsScreen> createState() => _PendingReportsScreenState();
}

class _PendingReportsScreenState extends State<PendingReportsScreen> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Reports')),
      body: RefreshIndicator(
        onRefresh: provider.loadPending,
        child: Builder(
          builder: (_) {
            if (provider.loading && provider.pendingReports.isEmpty)
              return const SkeletonList();
            if (provider.error != null && provider.pendingReports.isEmpty)
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
            if (provider.pendingReports.isEmpty)
              return const EmptyState(
                icon: Icons.fact_check_outlined,
                title: 'No pending reports',
                message: 'New submissions will appear here.',
              );
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.pendingReports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final report = provider.pendingReports[index];
                return ReportCard(
                  report: report,
                  onView: () {},
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Approve',
                        onPressed: () => _approve(report.id),
                        icon: const Icon(Icons.check_circle_outline),
                      ),
                      IconButton(
                        tooltip: 'Reject',
                        onPressed: () => _reject(report.id),
                        icon: const Icon(Icons.cancel_outlined),
                      ),
                    ],
                  ),
                );
              },
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
    ))
      return;
    final ok = await context.read<AdminProvider>().approve(id);
    if (mounted && ok) showAppMessage(context, 'Report approved');
  }

  Future<void> _reject(int id) async {
    if (!await confirmAction(
      context,
      'Reject report?',
      'This report will be marked as rejected.',
    ))
      return;
    final ok = await context.read<AdminProvider>().reject(id);
    if (mounted && ok) showAppMessage(context, 'Report rejected');
  }
}
