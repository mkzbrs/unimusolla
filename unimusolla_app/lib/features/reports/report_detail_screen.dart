import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/report_provider.dart';
import '../../widgets/app_states.dart';
import '../../widgets/network_image_box.dart';
import '../../widgets/status_badge.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key, required this.id});
  final int id;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
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
      appBar: AppBar(title: const Text('Report Detail')),
      body: Builder(
        builder: (_) {
          if (provider.loading && report == null)
            return const SkeletonList(itemCount: 3);
          if (provider.error != null && report == null)
            return ErrorState(
              message: provider.error!,
              onRetry: () => provider.loadDetail(widget.id),
            );
          if (report == null)
            return const EmptyState(
              icon: Icons.assignment_late_outlined,
              title: 'Not found',
              message: 'This report could not be loaded.',
            );
          return RefreshIndicator(
            onRefresh: () => provider.loadDetail(widget.id),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SizedBox(
                  height: 200,
                  child: PageView(
                    children: (report.images.isEmpty ? [null] : report.images)
                        .map(
                          (url) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: NetworkImageBox(url: url, height: 200),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  report.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                StatusBadge(status: report.status),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.place_outlined),
                  title: const Text('Location'),
                  subtitle: Text(report.location),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.near_me_outlined),
                  title: const Text('Exact Location'),
                  subtitle: Text(report.exactLocation),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.rate_review_outlined),
                  title: const Text('Admin Review Status'),
                  subtitle: Text(report.adminReview ?? report.status),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: report.facilities.labels
                      .map((label) => Chip(label: Text(label)))
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
