import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/views/screens/login_screen.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login screen elements are displayed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(TextButton), findsNWidgets(2));

    expect(find.text('Login'), findsNWidgets(2));
  });

  testWidgets('User can log in successfully', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'test@example.com',
    );

    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    await tester.tap(find.byKey(Key('login button')));
  });

  testWidgets('Login with different passwords', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    await tester.tap(find.byKey(Key('login button')));
    await tester.pumpAndSettle();

    expect(find.text('E-mail is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}
