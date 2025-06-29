// Basic widget test for Library Management System
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:library_management_system/main.dart';

void main() {
  testWidgets('App starts with login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: LibraryManagementApp()));

    // Wait for the widget tree to settle
    await tester.pumpAndSettle();

    // Verify that we start with login screen elements
    expect(find.text('Library Management'), findsOneWidget);
    expect(find.text('Welcome back! Please sign in to continue.'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
  });

  testWidgets('Login form has required fields', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: LibraryManagementApp()));

    // Wait for the widget tree to settle
    await tester.pumpAndSettle();

    // Verify that login form has email and password fields
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text("Don't have an account? "), findsOneWidget);
  });
}
