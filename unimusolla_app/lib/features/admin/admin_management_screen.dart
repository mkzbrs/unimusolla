import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../widgets/app_states.dart';
import '../../widgets/musolla_card.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key, required this.initialTab});
  final String initialTab;

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
    initialIndex: switch (widget.initialTab) {
      'musollas' => 1,
      'logs' => 2,
      _ => 0,
    },
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCurrent());
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _loadCurrent();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'USERS'),
            Tab(text: 'MUSOLLAS'),
            Tab(text: 'LOGS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_UsersTab(), _MusollasTab(), _LogsTab()],
      ),
    );
  }

  void _loadCurrent() {
    final admin = context.read<AdminProvider>();
    switch (_tabController.index) {
      case 1:
        admin.loadMusollas();
      case 2:
        admin.loadLogs();
      default:
        admin.loadUsers();
    }
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    if (provider.loading && provider.users.isEmpty) return const SkeletonList();
    if (provider.users.isEmpty)
      return const EmptyState(
        icon: Icons.people_outline,
        title: 'No users',
        message: 'Registered users will appear here.',
      );
    return RefreshIndicator(
      onRefresh: provider.loadUsers,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final user = provider.users[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(user.username),
              subtitle: Text('${user.email}\n${user.role.toUpperCase()}'),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteUser(context, user.id),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteUser(BuildContext context, int id) async {
    if (!await confirmAction(
      context,
      'Delete user?',
      'This user account will be removed.',
    ))
      return;
    final ok = await context.read<AdminProvider>().deleteUser(id);
    if (context.mounted && ok) showAppMessage(context, 'User deleted');
  }
}

class _MusollasTab extends StatelessWidget {
  const _MusollasTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    if (provider.loading && provider.musollas.isEmpty)
      return const SkeletonList();
    if (provider.musollas.isEmpty)
      return const EmptyState(
        icon: Icons.mosque_outlined,
        title: 'No musollas',
        message: 'Approved musollas will appear here.',
      );
    return RefreshIndicator(
      onRefresh: provider.loadMusollas,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.musollas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final musolla = provider.musollas[index];
          return MusollaCard(
            musolla: musolla,
            onTap: () => _deleteMusolla(context, musolla.id),
          );
        },
      ),
    );
  }

  Future<void> _deleteMusolla(BuildContext context, int id) async {
    if (!await confirmAction(
      context,
      'Delete musolla?',
      'This approved musolla will be removed.',
    ))
      return;
    final ok = await context.read<AdminProvider>().deleteMusolla(id);
    if (context.mounted && ok) showAppMessage(context, 'Musolla deleted');
  }
}

class _LogsTab extends StatelessWidget {
  const _LogsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    if (provider.loading && provider.logs.isEmpty) return const SkeletonList();
    if (provider.logs.isEmpty)
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No logs',
        message: 'Admin activity will appear here.',
      );
    return RefreshIndicator(
      onRefresh: provider.loadLogs,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.logs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final log = provider.logs[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(log.action),
              subtitle: Text('${log.description}\n${log.createdAt}'),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
