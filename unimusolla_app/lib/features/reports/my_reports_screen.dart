import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/report_provider.dart';
import '../../widgets/app_states.dart';
import '../../widgets/report_card.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ReportProvider>().loadList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reports/create'),
        icon: const Icon(Icons.add),
        label: const Text('Submit'),
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadList,
        child: Builder(
          builder: (_) {
            if (provider.loading && provider.reports.isEmpty)
              return const SkeletonList();
            if (provider.error != null && provider.reports.isEmpty)
              return ListView(
                children: [
                  SizedBox(
                    height: 480,
                    child: ErrorState(
                      message: provider.error!,
                      onRetry: provider.loadList,
                    ),
                  ),
                ],
              );
            if (provider.reports.isEmpty)
              return const EmptyState(
                icon: Icons.assignment_outlined,
                title: 'No reports',
                message: 'Submit a musolla report for admin review.',
              );
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: provider.reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final report = provider.reports[index];
                return ReportCard(
                  report: report,
                  onView: () => context.push('/reports/${report.id}'),
                  onEdit: report.canEdit
                      ? () => context.push('/reports/${report.id}/edit')
                      : null,
                  onDelete: () => _delete(report.id),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _delete(int id) async {
    if (!await confirmAction(
      context,
      'Delete report?',
      'This report will be removed permanently.',
    ))
      return;
    final ok = await context.read<ReportProvider>().delete(id);
    if (mounted && ok) showAppMessage(context, 'Report deleted');
  }
}
