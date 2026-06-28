import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/app_states.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _showInvalidEmail = false;
  bool _showInvalidPassword = false;

  static const _invalidEmailText = 'Invalid email';
  static const _invalidPasswordText = 'Invalid password';

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) _clearInvalidEmail();
    });
    _passwordFocus.addListener(() {
      if (_passwordFocus.hasFocus) _clearInvalidPassword();
    });
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.mosque,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const Key('login_email'),
                      controller: _email,
                      focusNode: _emailFocus,
                      onTap: _clearInvalidEmail,
                      style: TextStyle(
                        color: _showInvalidEmail
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (_showInvalidEmail) return null;
                        return value == null || !value.contains('@')
                            ? 'Enter a valid email'
                            : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const Key('login_password'),
                      controller: _password,
                      focusNode: _passwordFocus,
                      onTap: _clearInvalidPassword,
                      style: TextStyle(
                        color: _showInvalidPassword
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: !_showInvalidPassword,
                      validator: (value) {
                        if (_showInvalidPassword) return null;
                        return value == null || value.length < 8
                            ? 'Enter a valid password'
                            : null;
                      },
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: auth.loading ? null : _submit,
                      child: auth.loading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('Go To Register'),
                    ),
                    if (auth.error != null &&
                        !_showInvalidEmail &&
                        !_showInvalidPassword)
                      Text(
                        auth.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (ok) {
      showAppMessage(context, 'Login successful');
      context.go(auth.isAdmin ? '/admin' : '/home');
    } else {
      setState(() {
        _showInvalidEmail = true;
        _showInvalidPassword = true;
        _email.text = _invalidEmailText;
        _password.text = _invalidPasswordText;
      });
    }
  }

  void _clearInvalidEmail() {
    if (!_showInvalidEmail) return;
    setState(() {
      _showInvalidEmail = false;
      _email.clear();
    });
  }

  void _clearInvalidPassword() {
    if (!_showInvalidPassword) return;
    setState(() {
      _showInvalidPassword = false;
      _password.clear();
    });
  }
}
