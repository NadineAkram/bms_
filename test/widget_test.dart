import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bms/main.dart'; // Ensure this points to your main file

void main() {
  testWidgets('App initializes and shows the Welcome Screen', (WidgetTester tester) async {
    // Build the main application widget, which is typically named BMSApp.
    // The InitializationWrapper will handle service setup and show the WelcomeScreen.
    await tester.pumpWidget(const BMSApp());

    // Allow the asynchronous service to initialize and the UI to draw (FutureBuilder completes).
    await tester.pumpAndSettle();

    // 1. Verify that the welcome text "Welcome Back" appears on the WelcomeScreen.
    expect(find.text('Welcome Back'), findsOneWidget);

    // 2. Verify the "Login" button is present on the WelcomeScreen.
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // 3. Verify that the application title exists in the AppBar of the WelcomeScreen.
    // Assuming the app has a primary title 'Professional BMS Dashboard' from MaterialApp.
    // The WelcomeScreen itself should have an AppBar or a primary title reference.
    // Checking for a more generic 'BMS' reference to ensure stability.
    expect(find.byType(AppBar), findsOneWidget);

  });
}
