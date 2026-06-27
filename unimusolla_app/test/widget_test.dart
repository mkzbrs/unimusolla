import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:unimusolla_app/core/network/api_client.dart';
import 'package:unimusolla_app/core/storage/session_storage.dart';
import 'package:unimusolla_app/features/auth/login_screen.dart';
import 'package:unimusolla_app/features/auth/register_screen.dart';
import 'package:unimusolla_app/features/auth/splash_screen.dart';
import 'package:unimusolla_app/features/reports/report_form.dart';
import 'package:unimusolla_app/providers/auth_provider.dart';
import 'package:unimusolla_app/providers/report_provider.dart';

Widget _wrap(Widget child) {
  final storage = SessionStorage();
  final api = ApiClient(storage);
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider(api, storage)),
      ChangeNotifierProvider(create: (_) => ReportProvider(api, storage)),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('Splash shows UniMusolla branding', (tester) async {
    await tester.pumpWidget(_wrap(const SplashScreen()));
    expect(find.text('UniMusolla'), findsOneWidget);
    expect(find.byIcon(Icons.mosque), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Login form validates empty credentials', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
  });

  testWidgets('Register form validates password confirmation', (tester) async {
    await tester.pumpWidget(_wrap(const RegisterScreen()));
    await tester.enterText(find.byType(TextFormField).at(0), 'Student');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'student@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'password1');
    await tester.enterText(
      find.byKey(const Key('register_confirm_password')),
      'password2',
    );
    await tester.tap(find.text('Register'));
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('Report form validates required fields', (tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_wrap(const ReportFormScreen()));
    final submit = find.byType(FilledButton);
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    expect(find.text('Required'), findsNWidgets(3));
  });
}
