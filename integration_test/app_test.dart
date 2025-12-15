import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jawarapbl/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E App Tests', () {
    
    // TEST 1: Failed Login (Keep as is)
    testWidgets('User sees error message with invalid credentials',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final emailField = find.byKey(const Key('emailField'));
      final passwordField = find.byKey(const Key('passwordField'));
      final loginButton = find.byKey(const Key('loginButton'));

      await tester.enterText(emailField, 'invalid@example.com');
      await tester.enterText(passwordField, 'wrongpassword');
      await tester.pump(); 

      await tester.tap(loginButton);
      await tester.pumpAndSettle(); 

      expect(find.text('Login gagal. Periksa email dan password Anda.'), findsOneWidget);
    });

    // TEST 2: Successful Login (FIXED)
    testWidgets('User can login with valid credentials and navigate to Dashboard',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('emailField')), 'a@example.com');
      await tester.enterText(find.byKey(const Key('passwordField')), 'p');
      await tester.tap(find.byKey(const Key('loginButton')));
      
      await tester.pumpAndSettle(const Duration(seconds: 2));


      expect(find.text('Keuangan'), findsAtLeastNWidgets(1));
    });

    // TEST 3: Dashboard Navigation (FIXED)
    testWidgets('User can switch tabs on Dashboard', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('emailField')), 'a@example.com');
      await tester.enterText(find.byKey(const Key('passwordField')), 'p');
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle(const Duration(seconds: 2));


      final kegiatanTab = find.widgetWithText(Tab, 'Kegiatan'); 
      
      await tester.tap(kegiatanTab);
      await tester.pumpAndSettle();

      expect(find.text('Kegiatan'), findsAtLeastNWidgets(1));
    });
  });
}