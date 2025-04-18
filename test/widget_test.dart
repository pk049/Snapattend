// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eduvision/main.dart';
import 'package:eduvision/splashscreen.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: Splashscreen()));

    // Verify the splash screen appears
    expect(find.byType(Splashscreen), findsOneWidget);

    // You could add more assertions relevant to your splash screen
    // For example, if your splash screen has a logo or specific text:
    // expect(find.text('Eduvision'), findsOneWidget);
    // expect(find.byType(Image), findsOneWidget);
  });
}