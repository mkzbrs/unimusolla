import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/session_storage.dart';
import 'core/theme/app_theme.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/musolla_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/report_provider.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sessionStorage = SessionStorage();
  final apiClient = ApiClient(sessionStorage);
  final authProvider = AuthProvider(apiClient, sessionStorage);
  await authProvider.restoreSession();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        Provider.value(value: sessionStorage),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => MusollaProvider(apiClient)),
        ChangeNotifierProvider(
          create: (_) => ReportProvider(apiClient, sessionStorage),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(apiClient, sessionStorage),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminProvider(apiClient, sessionStorage),
        ),
      ],
      child: const UniMusollaApp(),
    ),
  );
}

class UniMusollaApp extends StatelessWidget {
  const UniMusollaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final router = AppRouter(auth).router;

    return MaterialApp.router(
      title: 'UniMusolla',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
