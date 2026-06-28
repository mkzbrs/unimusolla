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
  static const _surface = Color(0xFFF8F9FF);
  static const _onSurface = Color(0xFF121C2A);
  static const _onSurfaceVariant = Color(0xFF3F4944);
  static const _primary = Color(0xFF004532);
  static const _outlineVariant = Color(0xFFBEC9C2);

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
      backgroundColor: _surface,
      appBar: AppBar(
        title: Text(
          'My Reports',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: _primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: _surface,
        surfaceTintColor: _surface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: .12),
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
            if (provider.reports.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 672),
                      child: _ReportsEmptyState(
                        onSubmit: () => context.push('/reports/create'),
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 672),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SubmitReportBanner(
                          onSubmit: () => context.push('/reports/create'),
                        ),
                        const SizedBox(height: 16),
                        for (final report in provider.reports) ...[
                          ReportCard(
                            report: report,
                            onView: () => context.push('/reports/${report.id}'),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SubmitReportBanner extends StatelessWidget {
  const _SubmitReportBanner({required this.onSubmit});
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _MyReportsScreenState._outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.assignment_add,
              color: _MyReportsScreenState._primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'New report?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _MyReportsScreenState._onSurfaceVariant,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Submit'),
              style: FilledButton.styleFrom(
                backgroundColor: _MyReportsScreenState._primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsEmptyState extends StatelessWidget {
  const _ReportsEmptyState({required this.onSubmit});
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 16),
      child: Column(
        children: [
          Container(
            width: 152,
            height: 152,
            decoration: BoxDecoration(
              color: _MyReportsScreenState._primary.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 72,
              color: _MyReportsScreenState._primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Reports Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _MyReportsScreenState._onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Everything looks quiet. If you notice something that needs our attention at a musolla, let us know.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _MyReportsScreenState._onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: _MyReportsScreenState._primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: const StadiumBorder(),
            ),
            child: const Text('Submit New Report'),
          ),
        ],
      ),
    );
  }
}
