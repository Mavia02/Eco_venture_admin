import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:eco_venture_admin_portal/main.dart' as app;

/// Logic: Automated End-to-End tests for the Admin Portal.
/// Standard Location: project_root/integration_test/app_test.dart
void main() {
  // Logic: Connects the test script to the physical or virtual device hardware.
  final IntegrationTestWidgetsFlutterBinding binding =
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Logic: On Windows/Desktop, we ensure the window has a consistent size for testing
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  group('EcoVenture Admin Portal - End-to-End Journeys', () {

    testWidgets('Flow 1: Authentication to Dashboard Verification', (tester) async {
      // Logic: Starts the application from the entry point
      app.main();

      // Logic: Wait for the initial app build and splash screen to settle
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Action: Locate Login UI elements using more robust finders
      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

      // Using find.widgetWithText is more reliable than find.text on some desktop builds
      final loginBtn = find.widgetWithText(ElevatedButton, 'Login here');

      // Action: Simulate user typing
      await tester.enterText(emailField, 'admin@ecoventure.com');
      await tester.enterText(passwordField, 'admin123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Action: Tap Login
      await tester.tap(loginBtn);

      // Transition: Wait for the dashboard to load (Allowing time for Firebase Auth)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Terminal Verification: Confirm successful landing on the Admin Panel
      expect(find.text('Admin Panel'), findsOneWidget);
    });

    testWidgets('Flow 2: Module Library Tab Verification', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Action: Navigate to the Modules section from the Home Dashboard
      // Tapping the specific dashboard card text
      await tester.tap(find.text('Modules Uploaded'));
      await tester.pumpAndSettle();

      // Verification: Check if the TabBar items are present in the details view
      expect(find.text('Admin Library'), findsOneWidget);
      expect(find.text('Teacher Uploads'), findsOneWidget);

      // Action: Test tab switching
      await tester.tap(find.text('Teacher Uploads'));
      await tester.pumpAndSettle();
    });
  });
}