import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../features/admin/admin_dashboard_screen.dart';
import '../features/admin/admin_management_screen.dart';
import '../features/admin/pending_reports_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/home/user_home_screen.dart';
import '../features/musolla/musolla_detail_screen.dart';
import '../features/musolla/search_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/reports/report_detail_screen.dart';
import '../features/reports/report_form.dart';
import '../models/musolla.dart';
import '../models/report.dart';
import '../providers/auth_provider.dart';
import '../providers/report_provider.dart';

class AppRouter {
  AppRouter(this.authProvider);
  final AuthProvider authProvider;

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final path = state.uri.path;
      final public = path == '/' || path == '/login' || path == '/register';
      if (!authProvider.isAuthenticated && !public) return '/login';
      if (authProvider.isAuthenticated &&
          (path == '/login' || path == '/register')) {
        return authProvider.isAdmin ? '/admin' : '/home';
      }
      if (path.startsWith('/admin') &&
          authProvider.isAuthenticated &&
          !authProvider.isAdmin)
        return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, __) => const UserHomeScreen()),
      GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
      GoRoute(
        path: '/musolla/:id',
        builder: (_, state) => MusollaDetailScreen(
          id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: '/reports/create',
        builder: (_, state) => ReportFormScreen(
          sourceMusolla: state.extra is Musolla ? state.extra as Musolla : null,
        ),
      ),
      GoRoute(
        path: '/reports/:id',
        builder: (_, state) => ReportDetailScreen(
          id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: '/reports/:id/edit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          final reports = context.read<ReportProvider>().reports;
          final report = reports
              .where((item) => item.id == id)
              .cast<Report?>()
              .firstOrNull;
          if (report == null || !report.canEdit)
            return _MissingPendingReport(id: id);
          return ReportFormScreen(report: report);
        },
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(
        path: '/admin/pending',
        builder: (_, __) => const PendingReportsScreen(),
      ),
      GoRoute(
        path: '/admin/manage',
        builder: (_, state) => AdminManagementScreen(
          initialTab: state.uri.queryParameters['tab'] ?? 'users',
        ),
      ),
    ],
  );
}

class _MissingPendingReport extends StatelessWidget {
  const _MissingPendingReport({required this.id});
  final int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Report')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48),
              const SizedBox(height: 12),
              const Text('Only pending reports can be edited.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('Back to Reports'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
