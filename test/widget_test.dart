import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:district_direct/l10n/app_localizations.dart';
import 'package:district_direct/main.dart';

/// Wraps [child] in the minimal app shell needed to resolve AppLocalizations.
Widget buildApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: child,
  );
}

void main() {
  group('RoleSelectionScreen', () {
    testWidgets('displays the app name in the header', (tester) async {
      await tester.pumpWidget(buildApp(const RoleSelectionScreen()));
      await tester.pumpAndSettle();

      expect(find.text('DistrictDirect'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows the Government Service Portal subtitle', (tester) async {
      await tester.pumpWidget(buildApp(const RoleSelectionScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Government Service Portal'), findsOneWidget);
    });

    testWidgets('shows the Citizen Login card', (tester) async {
      await tester.pumpWidget(buildApp(const RoleSelectionScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Citizen Access'), findsOneWidget);
    });

    testWidgets('shows the Admin Login card', (tester) async {
      await tester.pumpWidget(buildApp(const RoleSelectionScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Admin Access'), findsOneWidget);
    });

    testWidgets('shows the Rwanda copyright footer', (tester) async {
      await tester.pumpWidget(buildApp(const RoleSelectionScreen()));
      await tester.pumpAndSettle();

      expect(find.text('© 2026 Government of Rwanda'), findsOneWidget);
    });

    testWidgets('shows description under the Citizen Login card', (tester) async {
      await tester.pumpWidget(buildApp(const RoleSelectionScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text('Report local issues and follow updates'),
        findsOneWidget,
      );
    });

    testWidgets('shows description under the Admin Login card', (tester) async {
      await tester.pumpWidget(buildApp(const RoleSelectionScreen()));
      await tester.pumpAndSettle();

      expect(
        find.text('Manage district services and incidents'),
        findsOneWidget,
      );
    });

    testWidgets('has a location_city icon in the logo area', (tester) async {
      await tester.pumpWidget(buildApp(const RoleSelectionScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.location_city), findsAtLeastNWidgets(1));
    });

    testWidgets('has an admin_panel_settings icon for the admin card',
        (tester) async {
      await tester.pumpWidget(buildApp(const RoleSelectionScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);
    });

    testWidgets('has a person icon for the citizen card', (tester) async {
      await tester.pumpWidget(buildApp(const RoleSelectionScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('both login buttons are tappable InkWell widgets', (tester) async {
      await tester.pumpWidget(buildApp(const RoleSelectionScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsAtLeastNWidgets(2));
    });
  });
}
