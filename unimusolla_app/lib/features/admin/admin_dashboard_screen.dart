import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_states.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AdminProvider>().loadDashboard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final stats = provider.stats;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (provider.loading && stats == null)
              const LinearProgressIndicator(),
            if (provider.error != null && stats == null)
              SizedBox(
                height: 420,
                child: ErrorState(
                  message: provider.error!,
                  onRetry: provider.loadDashboard,
                ),
              )
            else ...[
              GridView.count(
                crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 3 : 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3.2,
                children: [
                  _StatCard(
                    label: 'Users Count',
                    value: stats?.usersCount ?? 0,
                    icon: Icons.people_outline,
                  ),
                  _StatCard(
                    label: 'Musollas Count',
                    value: stats?.musollasCount ?? 0,
                    icon: Icons.mosque_outlined,
                  ),
                  _StatCard(
                    label: 'Pending Reports Count',
                    value: stats?.pendingReportsCount ?? 0,
                    icon: Icons.pending_actions_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _NavCard(
                title: 'Pending Reports',
                icon: Icons.fact_check_outlined,
                onTap: () => context.push('/admin/pending'),
              ),
              _NavCard(
                title: 'Users',
                icon: Icons.people_outline,
                onTap: () => context.push('/admin/manage?tab=users'),
              ),
              _NavCard(
                title: 'Musollas',
                icon: Icons.mosque_outlined,
                onTap: () => context.push('/admin/manage?tab=musollas'),
              ),
              _NavCard(
                title: 'Logs',
                icon: Icons.receipt_long_outlined,
                onTap: () => context.push('/admin/manage?tab=logs'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    if (!await confirmAction(context, 'Logout?', 'End the admin session?'))
      return;
    await context.read<AuthProvider>().logout();
    if (mounted) context.go('/login');
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
            Text('$value', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
