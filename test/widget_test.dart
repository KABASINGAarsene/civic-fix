// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:district_direct/main.dart';
import 'package:district_direct/providers/app_settings_provider.dart';

void main() {
  testWidgets('App launches with role selection screen', (
    WidgetTester tester,
  ) async {
    // Mock SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final appSettings = await AppSettingsProvider.create();

    // Build our app and trigger a frame.
    await tester.pumpWidget(DistrictDirectApp(appSettingsProvider: appSettings));

    // Verify that the role selection screen appears
    expect(find.text('DistrictDirect'), findsOneWidget);
    expect(find.text('Citizen Login'), findsOneWidget);
    expect(find.text('Admin Login'), findsOneWidget);
  });
}
