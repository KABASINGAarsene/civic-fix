import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:district_direct/l10n/app_localizations.dart';
import 'package:district_direct/providers/auth_provider.dart';
import 'package:district_direct/screens/auth/citizen_login_screen.dart';

/// Build the CitizenLoginScreen inside a minimal MaterialApp.
///
/// AuthProvider is registered lazily (provider default), so Firebase
/// is never accessed unless a method on the provider is actually called.
/// Our tests only exercise rendering and form validation, so Firebase
/// stays dormant throughout the suite.
Widget buildApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const CitizenLoginScreen(),
    ),
  );
}

void main() {
  group('CitizenLoginScreen – login mode (default)', () {
    testWidgets('shows the DistrictDirect brand name', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('DistrictDirect'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows the Hello Muraho greeting on the image banner',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Hello! Muraho!'), findsOneWidget);
    });

    testWidgets('shows the Rwanda +250 country prefix on the phone field',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('+250'), findsOneWidget);
    });

    testWidgets('shows a Login button in the default login mode', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('does not show Create Account in login mode', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsNothing);
    });

    testWidgets('shows the Forgot Password link', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('shows the Sign Up toggle link', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('shows the Zero-Trip Guarantee info card', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Zero-Trip Guarantee'), findsOneWidget);
    });
  });

  group('CitizenLoginScreen – signup mode toggle', () {
    testWidgets('tapping Sign Up switches the button label to Create Account',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('Full Name field appears after switching to signup mode',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Full Name'), findsOneWidget);
    });

    testWidgets('Email field appears after switching to signup mode',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Email Address'), findsOneWidget);
    });

    testWidgets('National ID field appears after switching to signup mode',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('National ID'), findsOneWidget);
    });

    testWidgets('switching back from signup to login hides the Name field',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Go to signup mode.
      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // The toggle link now shows "Login" — scroll to it and switch back.
      await tester.ensureVisible(find.text('Login').last);
      await tester.tap(find.text('Login').last);
      await tester.pumpAndSettle();

      expect(find.text('Full Name'), findsNothing);
    });
  });

  group('CitizenLoginScreen – form validation', () {
    testWidgets('shows required field error when Login is submitted empty',
        (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Scroll to and tap the Login button with all fields empty.
      final loginBtn = find.widgetWithText(ElevatedButton, 'Login');
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pump();

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets(
        'shows a password error when only the phone is filled', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Enter a valid phone so only the password field will fail.
      final phoneField = find.byType(TextFormField).first;
      await tester.enterText(phoneField, '781234567');
      await tester.pump();

      final loginBtn = find.widgetWithText(ElevatedButton, 'Login');
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pump();

      expect(find.text('Please enter your password'), findsOneWidget);
    });
  });
}
