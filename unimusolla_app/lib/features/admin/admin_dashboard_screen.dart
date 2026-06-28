import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/admin_models.dart';
import '../../models/musolla.dart';
import '../../models/report.dart';
import '../../models/user.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_states.dart';
import '../../widgets/network_image_box.dart';

enum _AdminTab { home, reports, users, musollas, activity }

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const _surface = Color(0xFFF8F9FF);
  static const _surfaceContainer = Color(0xFFE6EEFF);
  static const _surfaceContainerLow = Color(0xFFEFF4FF);
  static const _surfaceContainerHigh = Color(0xFFDEE9FC);
  static const _surfaceContainerHighest = Color(0xFFD9E3F6);
  static const _onSurface = Color(0xFF121C2A);
  static const _onSurfaceVariant = Color(0xFF3F4944);
  static const _outlineVariant = Color(0xFFBEC9C2);
  static const _primary = Color(0xFF004532);
  static const _primaryContainer = Color(0xFF065F46);
  static const _secondaryContainer = Color(0xFF82F5C1);
  static const _onSecondaryContainer = Color(0xFF00714E);
  static const _tertiaryFixed = Color(0xFFC3ECD7);
  static const _error = Color(0xFFBA1A1A);
  static const _errorContainer = Color(0xFFFFDAD6);
  static const _onErrorContainer = Color(0xFF93000A);

  _AdminTab _tab = _AdminTab.home;
  String _reportFilter = 'pending';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final auth = context.watch<AuthProvider>();
    final stats = provider.stats;
    final pendingReportsCount = provider.pendingReports.isNotEmpty
        ? provider.pendingReports
              .where((report) => report.status.toLowerCase() == 'pending')
              .length
        : stats?.pendingReportsCount ?? 0;
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 760;

    final content = RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          isWide ? 64 : 16,
          16,
          isWide ? 64 : 16,
          isWide ? 32 : 104,
        ),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (provider.loading &&
                      stats == null &&
                      _tab == _AdminTab.home)
                    const LinearProgressIndicator(minHeight: 2),
                  if (provider.error != null &&
                      stats == null &&
                      _tab == _AdminTab.home)
                    SizedBox(
                      height: 420,
                      child: ErrorState(
                        message: provider.error!,
                        onRetry: _loadDashboard,
                      ),
                    )
                  else
                    _buildTabContent(
                      provider,
                      stats,
                      pendingReportsCount,
                      isWide,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        surfaceTintColor: _surface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: .14),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: _primary, fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Tooltip(
              message: 'Profile',
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => context.push('/profile'),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: _outlineVariant,
                  child: Text(
                    _initials(auth.user?.username ?? 'Admin'),
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            color: _onSurfaceVariant,
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWide)
            _AdminSideNav(
              adminName: auth.user?.username ?? 'Admin User',
              selectedTab: _tab,
              onDashboard: () => _selectTab(_AdminTab.home),
              onMusollas: () => _selectTab(_AdminTab.musollas),
              onReports: () => _selectTab(_AdminTab.reports),
              onLogs: () => _selectTab(_AdminTab.users),
            ),
          Expanded(child: content),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : _AdminBottomNav(
              selectedTab: _tab,
              onHome: () => _selectTab(_AdminTab.home),
              onReports: () => _selectTab(_AdminTab.reports),
              onUsers: () => _selectTab(_AdminTab.users),
              onMusollas: () => _selectTab(_AdminTab.musollas),
            ),
      floatingActionButton: _tab == _AdminTab.musollas
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/reports/create'),
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Musolla'),
            )
          : null,
    );
  }

  Widget _buildTabContent(
    AdminProvider provider,
    DashboardStats? stats,
    int pendingReportsCount,
    bool isWide,
  ) {
    return switch (_tab) {
      _AdminTab.home => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _WelcomeBanner(),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: isWide ? 1.9 : .78,
            children: [
              _StatCard(
                label: 'Total Users',
                value: stats?.usersCount ?? 0,
                icon: Icons.person_outline,
                onTap: () => _selectTab(_AdminTab.users),
              ),
              _StatCard(
                label: 'Total Musollas',
                value: stats?.musollasCount ?? 0,
                icon: Icons.mosque_outlined,
                onTap: () => _selectTab(_AdminTab.musollas),
              ),
              _PendingCard(
                value: pendingReportsCount,
                onTap: () => _selectTab(_AdminTab.reports),
              ),
              _AdminLogsCard(
                logs: provider.logs,
                onApproved: () => _selectTab(_AdminTab.users),
                onRejected: () => _selectTab(_AdminTab.users),
                onAll: () => _selectTab(_AdminTab.activity),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _RecentActivityCard(
            logs: provider.logs,
            onViewAll: () => _selectTab(_AdminTab.activity),
          ),
        ],
      ),
      _AdminTab.reports => _ReportsSection(
        reports: provider.pendingReports,
        filter: _reportFilter,
        loading: provider.loading,
        onFilterChanged: _changeReportFilter,
        onApprove: _approveReport,
        onReject: _rejectReport,
        onView: _showReportDetails,
      ),
      _AdminTab.users => _UsersSection(
        users: provider.users,
        loading: provider.loading,
        onDelete: _deleteUser,
      ),
      _AdminTab.musollas => _MusollasSection(
        musollas: provider.musollas,
        loading: provider.loading,
        onOpen: (musolla) => context.push('/admin/musolla/${musolla.id}'),
        onDelete: _deleteMusolla,
      ),
      _AdminTab.activity => _ActivityLogSection(
        logs: provider.logs,
        loading: provider.loading,
      ),
    };
  }

  void _selectTab(_AdminTab tab) {
    if (_tab == tab) return;
    setState(() => _tab = tab);
    final provider = context.read<AdminProvider>();
    switch (tab) {
      case _AdminTab.reports:
        provider.loadReports(status: _reportFilter);
        break;
      case _AdminTab.users:
        provider.loadUsers();
        break;
      case _AdminTab.musollas:
        provider.loadMusollas();
        break;
      case _AdminTab.activity:
        provider.loadLogs();
        break;
      case _AdminTab.home:
        _loadDashboard();
        break;
    }
  }

  Future<void> _loadDashboard() async {
    final provider = context.read<AdminProvider>();
    await provider.loadDashboard();
    if (mounted) await provider.loadReports(status: _reportFilter);
    if (mounted) await provider.loadLogs();
  }

  Future<void> _changeReportFilter(String value) async {
    setState(() => _reportFilter = value);
    await context.read<AdminProvider>().loadReports(status: value);
  }

  Future<void> _approveReport(Report report) async {
    if (!await confirmAction(
      context,
      'Approve report?',
      'This will mark the report as approved.',
    )) {
      return;
    }
    final ok = await context.read<AdminProvider>().approve(report.id);
    if (!mounted || !ok) return;
    await _changeReportFilter('approved');
    showAppMessage(context, 'Report approved');
  }

  Future<void> _rejectReport(Report report) async {
    if (!await confirmAction(
      context,
      'Reject report?',
      'This report will be marked as rejected.',
    )) {
      return;
    }
    final ok = await context.read<AdminProvider>().reject(report.id);
    if (!mounted || !ok) return;
    await _changeReportFilter('rejected');
    showAppMessage(context, 'Report rejected');
  }

  Future<void> _showReportDetails(Report report) async {
    await context.push('/reports/${report.id}');
    if (mounted) {
      await context.read<AdminProvider>().loadReports(status: _reportFilter);
    }
  }

  Future<void> _deleteUser(User user) async {
    if (!await confirmAction(
      context,
      'Delete user?',
      '${user.username} will be removed.',
    ))
      return;
    final ok = await context.read<AdminProvider>().deleteUser(user.id);
    if (mounted && ok) showAppMessage(context, 'User deleted');
  }

  Future<void> _deleteMusolla(Musolla musolla) async {
    if (!await confirmAction(
      context,
      'Delete musolla?',
      '${musolla.name} will be removed.',
    ))
      return;
    final ok = await context.read<AdminProvider>().deleteMusolla(musolla.id);
    if (mounted && ok) showAppMessage(context, 'Musolla deleted');
  }

  Future<void> _logout() async {
    if (!await confirmAction(context, 'Logout?', 'End the admin session?')) {
      return;
    }
    await context.read<AuthProvider>().logout();
    if (mounted) context.go('/login');
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _AdminDashboardScreenState._primaryContainer,
            _AdminDashboardScreenState._primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 560;
            final content = Column(
              crossAxisAlignment: compact
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Administrator',
                  textAlign: compact ? TextAlign.center : TextAlign.start,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Oversee users, musollas, reports, and admin activity.',
                  textAlign: compact ? TextAlign.center : TextAlign.start,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: .9),
                  ),
                ),
              ],
            );
            return Row(children: [Expanded(child: content)]);
          },
        ),
      ),
    );
  }
}

class _AdminSideNav extends StatelessWidget {
  const _AdminSideNav({
    required this.adminName,
    required this.selectedTab,
    required this.onDashboard,
    required this.onMusollas,
    required this.onReports,
    required this.onLogs,
  });

  final String adminName;
  final _AdminTab selectedTab;
  final VoidCallback onDashboard;
  final VoidCallback onMusollas;
  final VoidCallback onReports;
  final VoidCallback onLogs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      decoration: const BoxDecoration(
        color: _AdminDashboardScreenState._surfaceContainerLow,
        border: Border(
          right: BorderSide(color: _AdminDashboardScreenState._outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 24, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Musolla Admin',
                  style: TextStyle(
                    color: _AdminDashboardScreenState._primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _AdminNavItem(
                icon: Icons.dashboard_outlined,
                selectedIcon: Icons.dashboard,
                label: 'Dashboard',
                selected: selectedTab == _AdminTab.home,
                onTap: onDashboard,
              ),
              _AdminNavItem(
                icon: Icons.mosque_outlined,
                selectedIcon: Icons.mosque,
                label: 'Musolla Management',
                selected: selectedTab == _AdminTab.musollas,
                onTap: onMusollas,
              ),
              _AdminNavItem(
                icon: Icons.report_outlined,
                selectedIcon: Icons.report,
                label: 'Reports',
                selected: selectedTab == _AdminTab.reports,
                onTap: onReports,
              ),
              _AdminNavItem(
                icon: Icons.group_outlined,
                selectedIcon: Icons.group,
                label: 'Users',
                selected: selectedTab == _AdminTab.users,
                onTap: onLogs,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: _AdminDashboardScreenState._surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          _AdminDashboardScreenState._secondaryContainer,
                      child: Text(
                        _initials(adminName),
                        style: const TextStyle(
                          color: _AdminDashboardScreenState._primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            adminName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _AdminDashboardScreenState._onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'Super Admin',
                            style: TextStyle(
                              color:
                                  _AdminDashboardScreenState._onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  const _AdminNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected
            ? _AdminDashboardScreenState._secondaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  color: selected
                      ? _AdminDashboardScreenState._onSecondaryContainer
                      : _AdminDashboardScreenState._onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? _AdminDashboardScreenState._onSecondaryContainer
                          : _AdminDashboardScreenState._onSurfaceVariant,
                      fontWeight: FontWeight.w800,
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

class _AdminBottomNav extends StatelessWidget {
  const _AdminBottomNav({
    required this.selectedTab,
    required this.onHome,
    required this.onReports,
    required this.onUsers,
    required this.onMusollas,
  });

  final _AdminTab selectedTab;
  final VoidCallback onHome;
  final VoidCallback onReports;
  final VoidCallback onUsers;
  final VoidCallback onMusollas;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border.all(color: _AdminDashboardScreenState._outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .14),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: switch (selectedTab) {
          _AdminTab.reports => 1,
          _AdminTab.users => 2,
          _AdminTab.musollas => 3,
          _ => 0,
        },
        onDestinationSelected: (index) {
          if (index == 1) return onReports();
          if (index == 2) return onUsers();
          if (index == 3) return onMusollas();
          return onHome();
        },
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: _AdminDashboardScreenState._secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Report',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'User',
          ),
          NavigationDestination(
            icon: Icon(Icons.mosque_outlined),
            selectedIcon: Icon(Icons.mosque),
            label: 'Musolla',
          ),
        ],
      ),
    );
  }
}

class _ReportsSection extends StatelessWidget {
  const _ReportsSection({
    required this.reports,
    required this.filter,
    required this.loading,
    required this.onFilterChanged,
    required this.onApprove,
    required this.onReject,
    required this.onView,
  });

  final List<Report> reports;
  final String filter;
  final bool loading;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<Report> onApprove;
  final ValueChanged<Report> onReject;
  final ValueChanged<Report> onView;

  @override
  Widget build(BuildContext context) {
    final filtered = reports
        .where((report) => report.status.toLowerCase() == filter)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: 'Issue Reports',
          subtitle: 'Manage submitted reports',
          trailing: _SegmentedFilter(
            value: filter,
            values: const ['pending', 'approved', 'rejected'],
            onChanged: onFilterChanged,
          ),
        ),
        if (loading && reports.isEmpty)
          const SizedBox(height: 640, child: SkeletonList())
        else if (filtered.isEmpty)
          EmptyState(
            icon: Icons.assignment_outlined,
            title: 'No ${filter.toLowerCase()} reports',
            message: 'Reports will appear here when available.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 980
                  ? 3
                  : constraints.maxWidth >= 620
                  ? 2
                  : 1;
              return GridView.builder(
                itemCount: filtered.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: columns == 1 ? 1.25 : 1.05,
                ),
                itemBuilder: (context, index) {
                  final report = filtered[index];
                  return _ReportAdminCard(
                    report: report,
                    onView: () => onView(report),
                    onApprove: filter == 'pending'
                        ? () => onApprove(report)
                        : null,
                    onReject: filter == 'pending'
                        ? () => onReject(report)
                        : null,
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

class _UsersSection extends StatelessWidget {
  const _UsersSection({
    required this.users,
    required this.loading,
    required this.onDelete,
  });

  final List<User> users;
  final bool loading;
  final ValueChanged<User> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(
          title: 'User Management',
          subtitle: 'Manage registered users.',
        ),
        if (loading && users.isEmpty)
          const SizedBox(height: 640, child: SkeletonList())
        else if (users.isEmpty)
          const EmptyState(
            icon: Icons.people_outline,
            title: 'No users',
            message: 'Registered users will appear here.',
          )
        else
          _GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: users
                  .map(
                    (user) => _UserAdminRow(
                      user: user,
                      onDelete: () => onDelete(user),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _MusollasSection extends StatelessWidget {
  const _MusollasSection({
    required this.musollas,
    required this.loading,
    required this.onOpen,
    required this.onDelete,
  });

  final List<Musolla> musollas;
  final bool loading;
  final ValueChanged<Musolla> onOpen;
  final ValueChanged<Musolla> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(
          title: 'Live Musollas',
          subtitle: 'Manage musollas.',
        ),
        if (loading && musollas.isEmpty)
          const SizedBox(height: 640, child: SkeletonList())
        else if (musollas.isEmpty)
          const EmptyState(
            icon: Icons.mosque_outlined,
            title: 'No musollas',
            message: 'Approved musollas will appear here.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 2 : 1;
              return GridView.builder(
                itemCount: musollas.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: columns == 1 ? 2.45 : 2.2,
                ),
                itemBuilder: (context, index) {
                  final musolla = musollas[index];
                  return _MusollaAdminCard(
                    musolla: musolla,
                    onOpen: () => onOpen(musolla),
                    onDelete: () => onDelete(musolla),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

class _ActivityLogSection extends StatelessWidget {
  const _ActivityLogSection({required this.logs, required this.loading});

  final List<AdminLog> logs;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final sorted = [...logs]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(
          title: 'Recent Actions',
          subtitle: 'Chronological admin activity log.',
        ),
        if (loading && logs.isEmpty)
          const SizedBox(height: 640, child: SkeletonList())
        else if (sorted.isEmpty)
          const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No recent activity',
            message: 'Admin actions will appear here.',
          )
        else
          _GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [for (final log in sorted) _ActivityLogTile(log: log)],
            ),
          ),
      ],
    );
  }
}

class _ActivityLogTile extends StatelessWidget {
  const _ActivityLogTile({required this.log});

  final AdminLog log;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _AdminDashboardScreenState._surfaceContainerHigh,
            child: Icon(
              _statusFrom(log.action) == 'approved'
                  ? Icons.check_circle_outline
                  : _statusFrom(log.action) == 'rejected'
                  ? Icons.cancel_outlined
                  : Icons.history,
              size: 20,
              color: _AdminDashboardScreenState._primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.action,
                  style: const TextStyle(
                    color: _AdminDashboardScreenState._onSurface,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (log.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    log.description,
                    style: const TextStyle(
                      color: _AdminDashboardScreenState._onSurfaceVariant,
                    ),
                  ),
                ],
                if (log.createdAt.trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    log.createdAt,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _AdminDashboardScreenState._onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle, this.trailing});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final titleBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _AdminDashboardScreenState._primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: _AdminDashboardScreenState._onSurfaceVariant,
                  ),
                ),
              ],
            ],
          );
          if (trailing == null) return titleBlock;
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [titleBlock, const SizedBox(height: 16), trailing!],
            );
          }
          return Row(
            children: [
              Expanded(child: titleBlock),
              const SizedBox(width: 16),
              trailing!,
            ],
          );
        },
      ),
    );
  }
}

class _SegmentedFilter extends StatelessWidget {
  const _SegmentedFilter({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth.isFinite ? constraints.maxWidth : 340,
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _AdminDashboardScreenState._surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: values.map((item) {
              final selected = item == value;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    child: InkWell(
                      onTap: () => onChanged(item),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _titleCase(item),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? _AdminDashboardScreenState._primary
                                : _AdminDashboardScreenState._onSurfaceVariant,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _ReportImagePreview extends StatelessWidget {
  const _ReportImagePreview({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    final image = report.images.isEmpty ? null : report.images.first;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 116,
        width: double.infinity,
        child: NetworkImageBox(url: image, width: double.infinity, height: 116),
      ),
    );
  }
}

class _ReportAdminCard extends StatelessWidget {
  const _ReportAdminCard({
    required this.report,
    required this.onView,
    required this.onApprove,
    required this.onReject,
  });

  final Report report;
  final VoidCallback onView;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReportImagePreview(report: report),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _Badge(label: report.name)),
              const SizedBox(width: 8),
              _StatusPill(status: report.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            report.location.isEmpty ? report.name : report.location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _AdminDashboardScreenState._onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              report.exactLocation.isEmpty
                  ? 'No extra details provided.'
                  : report.exactLocation,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _AdminDashboardScreenState._onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View Details'),
                ),
              ),
              if (onApprove == null && onReject == null) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Open report',
                  onPressed: onView,
                  icon: const Icon(Icons.arrow_forward),
                  color: _AdminDashboardScreenState._primary,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _UserAdminRow extends StatelessWidget {
  const _UserAdminRow({required this.user, required this.onDelete});

  final User user;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final roleBadge = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: _Badge(label: _titleCase(user.role), subdued: true),
        );
        final identity = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _AdminDashboardScreenState._secondaryContainer,
              child: Text(
                _initials(user.username),
                style: const TextStyle(
                  color: _AdminDashboardScreenState._primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          user.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _AdminDashboardScreenState._onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      roleBadge,
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _AdminDashboardScreenState._onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        final actionButtons = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                tooltip: 'Delete user',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: _AdminDashboardScreenState._error,
              ),
            ),
          ],
        );
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _AdminDashboardScreenState._outlineVariant,
                width: .5,
              ),
            ),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    identity,
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: actionButtons,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: identity),
                    const SizedBox(width: 12),
                    actionButtons,
                  ],
                ),
        );
      },
    );
  }
}

class _MusollaAdminCard extends StatelessWidget {
  const _MusollaAdminCard({
    required this.musolla,
    required this.onOpen,
    required this.onDelete,
  });

  final Musolla musolla;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: _AdminDashboardScreenState._outlineVariant.withValues(
                alpha: .55,
              ),
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                child: SizedBox(
                  width: 132,
                  height: double.infinity,
                  child: NetworkImageBox(
                    url: musolla.imageUrl,
                    width: 132,
                    height: double.infinity,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        musolla.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: _AdminDashboardScreenState._onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              musolla.exactLocation.isEmpty
                                  ? musolla.location
                                  : musolla.exactLocation,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _AdminDashboardScreenState
                                    ._onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Delete'),
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  _AdminDashboardScreenState._error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .82),
        border: Border.all(
          color: _AdminDashboardScreenState._outlineVariant.withValues(
            alpha: .45,
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.subdued = false});

  final String label;
  final bool subdued;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: subdued
            ? _AdminDashboardScreenState._tertiaryFixed
            : _AdminDashboardScreenState._primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _AdminDashboardScreenState._primary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconTile(icon: icon),
          const Spacer(),
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: _AdminDashboardScreenState._onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _AdminDashboardScreenState._onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.value, required this.onTap});

  final int value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      color: _AdminDashboardScreenState._errorContainer,
      borderColor: _AdminDashboardScreenState._error.withValues(alpha: .18),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _IconTile(
            icon: Icons.report_outlined,
            color: _AdminDashboardScreenState._error,
            background: Colors.white54,
          ),
          const Spacer(),
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: _AdminDashboardScreenState._onErrorContainer,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'PENDING REPORTS',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _AdminDashboardScreenState._onErrorContainer,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminLogsCard extends StatelessWidget {
  const _AdminLogsCard({
    required this.logs,
    required this.onApproved,
    required this.onRejected,
    required this.onAll,
  });

  final List<AdminLog> logs;
  final VoidCallback onApproved;
  final VoidCallback onRejected;
  final VoidCallback onAll;

  @override
  Widget build(BuildContext context) {
    final approved = logs
        .where((log) => log.action.toLowerCase().contains('approv'))
        .length;
    final rejected = logs
        .where((log) => log.action.toLowerCase().contains('reject'))
        .length;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _AdminDashboardScreenState._outlineVariant),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: const BoxDecoration(
              color: _AdminDashboardScreenState._surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: _AdminDashboardScreenState._outlineVariant,
                ),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Admin Logs',
                    style: TextStyle(
                      color: _AdminDashboardScreenState._onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Icon(
                  Icons.history,
                  size: 28,
                  color: _AdminDashboardScreenState._onSurfaceVariant,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LogShortcut(
                    icon: Icons.verified_outlined,
                    label: 'Approved',
                    count: approved,
                    color: _AdminDashboardScreenState._onSecondaryContainer,
                    onTap: onApproved,
                  ),
                  _LogShortcut(
                    icon: Icons.cancel_outlined,
                    label: 'Rejected',
                    count: rejected,
                    color: _AdminDashboardScreenState._error,
                    onTap: onRejected,
                  ),
                  _LogShortcut(
                    icon: Icons.list_alt_outlined,
                    label: 'All Logs',
                    count: logs.length,
                    selected: true,
                    color: _AdminDashboardScreenState._primary,
                    onTap: onAll,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.logs, required this.onViewAll});

  final List<AdminLog> logs;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final recent = logs.take(4).toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _AdminDashboardScreenState._outlineVariant),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _AdminDashboardScreenState._onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: _AdminDashboardScreenState._outlineVariant,
          ),
          if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.all(14),
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No recent activity',
                message: 'Admin actions will appear here.',
              ),
            )
          else
            ...recent.map((log) => _ActivityRow(log: log)),
          const Divider(
            height: 1,
            color: _AdminDashboardScreenState._outlineVariant,
          ),
          TextButton(
            onPressed: onViewAll,
            child: const Text('View All Recent Actions'),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.log});

  final AdminLog log;

  @override
  Widget build(BuildContext context) {
    final status = _statusFrom(log.action);

    return InkWell(
      onTap: () => context.push('/admin/manage?tab=logs'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: _AdminDashboardScreenState._surfaceContainerHigh,
              child: Text(
                _initials(log.action),
                style: const TextStyle(
                  color: _AdminDashboardScreenState._primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Text(
                log.action,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                log.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _AdminDashboardScreenState._onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _StatusPill(status: status),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.child,
    this.color = Colors.white,
    this.borderColor = _AdminDashboardScreenState._outlineVariant,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    this.color = _AdminDashboardScreenState._primary,
    this.background = _AdminDashboardScreenState._surfaceContainerHigh,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}

class _LogShortcut extends StatelessWidget {
  const _LogShortcut({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: selected
                ? _AdminDashboardScreenState._surfaceContainerHigh
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? _AdminDashboardScreenState._outlineVariant
                  : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _AdminDashboardScreenState._onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: _AdminDashboardScreenState._onSurfaceVariant,
                )
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: label == 'Rejected'
                        ? _AdminDashboardScreenState._errorContainer
                        : _AdminDashboardScreenState._secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: label == 'Rejected'
                            ? _AdminDashboardScreenState._onErrorContainer
                            : _AdminDashboardScreenState._onSecondaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
    final (background, foreground) = switch (normalized) {
      'approved' => (
        _AdminDashboardScreenState._tertiaryFixed,
        _AdminDashboardScreenState._primary,
      ),
      'rejected' => (
        _AdminDashboardScreenState._errorContainer,
        _AdminDashboardScreenState._error,
      ),
      _ => (
        _AdminDashboardScreenState._surfaceContainerHighest,
        _AdminDashboardScreenState._onSurfaceVariant,
      ),
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
          style: TextStyle(
            color: foreground,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

String _statusFrom(String action) {
  final normalized = action.toLowerCase();
  if (normalized.contains('approv')) return 'Approved';
  if (normalized.contains('reject')) return 'Rejected';
  if (normalized.contains('delete') || normalized.contains('dismiss')) {
    return 'Dismissed';
  }
  return 'Pending';
}

String _titleCase(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return trimmed;
  return '${trimmed.characters.first.toUpperCase()}${trimmed.substring(1).toLowerCase()}';
}

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'A';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}
