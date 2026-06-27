import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/app_states.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _picker = ImagePicker();
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _username.text = context.read<AuthProvider>().user?.username ?? '';
  }

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(
                _image == null ? 'Choose Profile Picture' : _image!.name,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: provider.loading ? null : _submit,
              child: provider.loading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Profile'),
            ),
            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  provider.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
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
      showAppMessage(context, 'Profile updated');
      context.pop();
    }
  }
}
