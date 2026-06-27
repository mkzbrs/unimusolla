import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_states.dart';
import '../../widgets/network_image_box.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ProfileProvider>().loadProfile(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final auth = context.watch<AuthProvider>();
    final user = profileProvider.profile ?? auth.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: RefreshIndicator(
        onRefresh: profileProvider.loadProfile,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (profileProvider.loading && user == null)
              const LinearProgressIndicator(),
            if (user == null)
              const SizedBox(
                height: 420,
                child: EmptyState(
                  icon: Icons.person_off_outlined,
                  title: 'No profile',
                  message: 'Login again to load your profile.',
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ClipOval(
                        child: NetworkImageBox(
                          url: user.profileImage,
                          width: 104,
                          height: 104,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.username,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(user.email),
                      const SizedBox(height: 8),
                      Chip(label: Text(user.role.toUpperCase())),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => context.push('/profile/edit'),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Profile'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    if (!await confirmAction(
      context,
      'Logout?',
      'You will need to login again to continue.',
    ))
      return;
    await context.read<AuthProvider>().logout();
    if (mounted) context.go('/login');
  }
}
