// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:district_direct/main.dart';

void main() {
  testWidgets('App launches with role selection screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DistrictDirectApp());

    // Verify that the role selection screen appears
    expect(find.text('DistrictDirect'), findsOneWidget);
    expect(find.text('Citizen Login'), findsOneWidget);
    expect(find.text('Admin Login'), findsOneWidget);
  });
}
