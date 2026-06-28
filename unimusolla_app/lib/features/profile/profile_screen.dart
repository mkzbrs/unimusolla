import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
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
  static const _surface = Color(0xFFF8F9FF);
  static const _surfaceContainer = Color(0xFFE6EEFF);
  static const _surfaceContainerLow = Color(0xFFEFF4FF);
  static const _surfaceContainerLowest = Colors.white;
  static const _onSurface = Color(0xFF121C2A);
  static const _onSurfaceVariant = Color(0xFF3F4944);
  static const _outlineVariant = Color(0xFFBEC9C2);
  static const _primary = Color(0xFF004532);
  static const _primaryFixed = Color(0xFFA6F2D1);
  static const _error = Color(0xFFBA1A1A);

  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _picker = ImagePicker();
  XFile? _image;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ProfileProvider>().loadProfile(),
    );
  }

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final auth = context.watch<AuthProvider>();
    final user = profileProvider.profile ?? auth.user;

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
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
        onRefresh: profileProvider.loadProfile,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: user == null
                    ? const SizedBox(
                        height: 420,
                        child: EmptyState(
                          icon: Icons.person_off_outlined,
                          title: 'No profile',
                          message: 'Login again to load your profile.',
                        ),
                      )
                    : _ProfileContent(
                        user: user,
                        editing: _editing,
                        loading: profileProvider.loading,
                        error: profileProvider.error,
                        formKey: _formKey,
                        username: _username,
                        selectedImage: _image,
                        onEdit: () => _startEditing(user),
                        onCancel: () => _stopEditing(user),
                        onPickImage: _pickImage,
                        onSave: _submit,
                        onLogout: _logout,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startEditing(User user) {
    setState(() {
      _editing = true;
      _image = null;
      _username.text = user.username;
    });
  }

  void _stopEditing(User user) {
    setState(() {
      _editing = false;
      _image = null;
      _username.text = user.username;
    });
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final nextUser = await context.read<ProfileProvider>().updateProfile(
      _username.text.trim(),
      _image,
    );
    if (!mounted) return;
    if (nextUser != null) {
      await context.read<AuthProvider>().setUser(nextUser);
      if (!mounted) return;
      setState(() {
        _editing = false;
        _image = null;
      });
      showAppMessage(context, 'Profile updated');
    }
  }

  Future<void> _logout() async {
    if (!await confirmAction(
      context,
      'Logout?',
      'You will need to login again to continue.',
    )) {
      return;
    }
    await context.read<AuthProvider>().logout();
    if (mounted) context.go('/login');
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.user,
    required this.editing,
    required this.loading,
    required this.error,
    required this.formKey,
    required this.username,
    required this.selectedImage,
    required this.onEdit,
    required this.onCancel,
    required this.onPickImage,
    required this.onSave,
    required this.onLogout,
  });

  final User user;
  final bool editing;
  final bool loading;
  final String? error;
  final GlobalKey<FormState> formKey;
  final TextEditingController username;
  final XFile? selectedImage;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onPickImage;
  final VoidCallback onSave;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileHero(
          user: user,
          editing: editing,
          loading: loading,
          selectedImage: selectedImage,
          onEdit: onEdit,
          onPickImage: onPickImage,
        ),
        const SizedBox(height: 24),
        _InfoCard(
          user: user,
          editing: editing,
          loading: loading,
          error: error,
          formKey: formKey,
          username: username,
          selectedImage: selectedImage,
          onSave: onSave,
          onCancel: onCancel,
          onLogout: onLogout,
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.user,
    required this.editing,
    required this.loading,
    required this.selectedImage,
    required this.onEdit,
    required this.onPickImage,
  });

  final User user;
  final bool editing;
  final bool loading;
  final XFile? selectedImage;
  final VoidCallback onEdit;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 192,
              height: 192,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _ProfileScreenState._surfaceContainerLow,
                border: Border.all(
                  color: _ProfileScreenState._primaryFixed,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: NetworkImageBox(
                  url: user.profileImage,
                  width: 184,
                  height: 184,
                ),
              ),
            ),
            if (editing)
              IconButton.filled(
                onPressed: loading ? null : onPickImage,
                icon: const Icon(Icons.photo_camera_outlined),
                tooltip: 'Choose profile picture',
                style: IconButton.styleFrom(
                  backgroundColor: _ProfileScreenState._primary,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
        if (editing && selectedImage != null) ...[
          const SizedBox(height: 8),
          Text(
            selectedImage!.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _ProfileScreenState._onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          user.username,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: _ProfileScreenState._onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        if (!editing)
          OutlinedButton.icon(
            onPressed: loading ? null : onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Profile'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _ProfileScreenState._primary,
              side: const BorderSide(color: _ProfileScreenState._primary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.user,
    required this.editing,
    required this.loading,
    required this.error,
    required this.formKey,
    required this.username,
    required this.selectedImage,
    required this.onSave,
    required this.onCancel,
    required this.onLogout,
  });

  final User user;
  final bool editing;
  final bool loading;
  final String? error;
  final GlobalKey<FormState> formKey;
  final TextEditingController username;
  final XFile? selectedImage;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _ProfileScreenState._surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              if (editing)
                _EditableNameField(controller: username)
              else
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Full Name',
                  value: user.username,
                ),
              const SizedBox(height: 24),
              _InfoRow(
                icon: Icons.mail_outline,
                label: 'Email',
                value: user.email.isEmpty ? '-' : user.email,
              ),
              if (editing) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: loading ? null : onCancel,
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: loading ? null : onSave,
                        child: loading
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              const Divider(color: _ProfileScreenState._outlineVariant),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: loading ? null : onLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: TextButton.styleFrom(
                  foregroundColor: _ProfileScreenState._error,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _ProfileScreenState._surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _ProfileScreenState._primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _ProfileScreenState._onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _ProfileScreenState._onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditableNameField extends StatelessWidget {
  const _EditableNameField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: 'Full Name',
        prefixIcon: const Icon(Icons.person_outline),
        filled: true,
        fillColor: _ProfileScreenState._surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: _ProfileScreenState._outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: _ProfileScreenState._primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
