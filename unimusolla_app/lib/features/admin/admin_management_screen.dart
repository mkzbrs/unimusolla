import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/musolla.dart';
import '../../models/user.dart';
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
        break;
      case 2:
        admin.loadLogs();
        break;
      default:
        admin.loadUsers();
        break;
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
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      user.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RoleBadge(role: user.role),
                ],
              ),
              subtitle: Text(user.email),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: 'Edit user',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editUser(context, user),
                  ),
                  IconButton(
                    tooltip: 'Delete user',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteUser(context, user.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _editUser(BuildContext context, User user) async {
    final username = TextEditingController(text: user.username);
    final email = TextEditingController(text: user.email);
    var role = user.role;
    var didClose = false;

    final result =
        await showDialog<({String username, String email, String role})>(
          context: context,
          builder: (dialogContext) => StatefulBuilder(
            builder: (dialogContext, setDialogState) => AlertDialog(
              title: const Text('Edit user'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: username,
                      decoration: const InputDecoration(labelText: 'Username'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: role,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: const [
                        DropdownMenuItem(value: 'user', child: Text('User')),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (value) =>
                          setDialogState(() => role = value ?? role),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: didClose
                      ? null
                      : () {
                          setDialogState(() => didClose = true);
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: didClose
                      ? null
                      : () {
                          final nextUsername = username.text.trim();
                          final nextEmail = email.text.trim();
                          if (nextUsername.isEmpty || nextEmail.isEmpty) return;
                          setDialogState(() => didClose = true);
                          Navigator.of(dialogContext).pop((
                            username: nextUsername,
                            email: nextEmail,
                            role: role,
                          ));
                        },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );

    username.dispose();
    email.dispose();
    if (result == null || !context.mounted) return;
    final ok = await context.read<AdminProvider>().updateUser(
      id: user.id,
      username: result.username,
      email: result.email,
      role: result.role,
    );
    if (context.mounted && ok) showAppMessage(context, 'User updated');
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

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role.toLowerCase() == 'admin';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isAdmin ? const Color(0xFFC3ECD7) : const Color(0xFFE6EEFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBEC9C2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          role.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isAdmin ? const Color(0xFF294E3F) : const Color(0xFF3F4944),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: .5,
          ),
        ),
      ),
    );
  }
}

class _MusollasTab extends StatefulWidget {
  const _MusollasTab();

  @override
  State<_MusollasTab> createState() => _MusollasTabState();
}

class _MusollasTabState extends State<_MusollasTab> {
  static const _blocks = [
    'All Blocks',
    'DKG 1',
    'DKG 2',
    'DKG 3',
    'DKG 4',
    'DKG 5',
    'DKG 6',
    'DKG 7',
  ];

  final _searchController = TextEditingController();
  String _query = '';
  String _selectedBlock = 'All Blocks';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    if (provider.loading && provider.musollas.isEmpty)
      return const SkeletonList();

    if (provider.error != null && provider.musollas.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: 480,
            child: ErrorState(
              message: provider.error!,
              onRetry: provider.loadMusollas,
            ),
          ),
        ],
      );
    }

    final musollas =
        provider.musollas.where((musolla) {
          final text =
              '${musolla.name} ${musolla.location} ${musolla.exactLocation}'
                  .toLowerCase();
          final matchesQuery = _query.isEmpty || text.contains(_query);
          final matchesBlock =
              _selectedBlock == 'All Blocks' ||
              _blockFor(musolla) == _selectedBlock;
          return matchesQuery && matchesBlock;
        }).toList()..sort((a, b) {
          final availability = b.available.toString().compareTo(
            a.available.toString(),
          );
          if (availability != 0) return availability;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

    return RefreshIndicator(
      onRefresh: provider.loadMusollas,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () => context.push('/reports/create'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Musolla'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _searchPanel(),
                ],
              ),
            ),
          ),
          if (provider.musollas.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.mosque_outlined,
                title: 'No musollas',
                message: 'Approved musollas will appear here.',
              ),
            )
          else if (musollas.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.search_off_outlined,
                title: 'No matching musollas',
                message: 'Try another keyword or block filter.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final columns = width >= 1040
                      ? 3
                      : width >= 680
                      ? 2
                      : 1;
                  return SliverGrid.builder(
                    itemCount: musollas.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: columns == 1 ? 1.04 : .92,
                    ),
                    itemBuilder: (context, index) {
                      final musolla = musollas[index];
                      return _AdminMusollaCard(
                        musolla: musolla,
                        onTap: () =>
                            context.push('/admin/musolla/${musolla.id}'),
                        onDelete: () => _deleteMusolla(context, musolla.id),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _searchPanel() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFBEC9C2).withValues(alpha: .5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search Musollas...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6F7973)),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close),
                        color: const Color(0xFF004532),
                      ),
                filled: true,
                fillColor: const Color(0xFFF8F9FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFBEC9C2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFBEC9C2)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _blocks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final block = _blocks[index];
                  final selected = block == _selectedBlock;
                  return ChoiceChip(
                    label: Text(block),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedBlock = block),
                    labelStyle: TextStyle(
                      color: selected
                          ? const Color(0xFF8BD6B7)
                          : const Color(0xFF3F4944),
                      fontWeight: FontWeight.w700,
                    ),
                    selectedColor: const Color(0xFF065F46),
                    backgroundColor: const Color(0xFFF8F9FF),
                    side: BorderSide(
                      color: selected
                          ? Colors.transparent
                          : const Color(0xFFBEC9C2),
                    ),
                    shape: const StadiumBorder(),
                    showCheckmark: false,
                  );
                },
              ),
            ),
          ],
        ),
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

  String _blockFor(Musolla musolla) {
    final source = '${musolla.location} ${musolla.name}'.trim();
    final dkgMatch = RegExp(
      r'\bDKG\s*\d+\b',
      caseSensitive: false,
    ).firstMatch(source);
    if (dkgMatch != null) {
      return dkgMatch.group(0)!.toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
    }
    return 'All Blocks';
  }
}

class _AdminMusollaCard extends StatelessWidget {
  const _AdminMusollaCard({
    required this.musolla,
    required this.onTap,
    required this.onDelete,
  });

  final Musolla musolla;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: MusollaCard(musolla: musolla, onTap: onTap),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 2,
            child: IconButton(
              tooltip: 'Delete musolla',
              icon: const Icon(Icons.delete_outline),
              color: Theme.of(context).colorScheme.error,
              onPressed: onDelete,
            ),
          ),
        ),
      ],
    );
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
