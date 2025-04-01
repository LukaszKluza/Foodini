import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/views/screens/register_screen.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Register screen elements are displayed', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegisterScreen(),
      ),
    );

    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);

    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('Country picker opens on tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegisterScreen(),
      ),
    );

    final countryField = find.byType(TextFormField).at(2);

    await tester.tap(countryField);
    await tester.pumpAndSettle();
  });

  testWidgets('Register button triggers registration process', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegisterScreen(),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'John');
    await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
    await tester.enterText(find.byType(TextFormField).at(3), 'john@example.com');
    await tester.enterText(find.byType(TextFormField).at(4), 'password123');
    await tester.enterText(find.byType(TextFormField).at(5), 'password123');

    await tester.tap(find.byKey(Key('ageDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownMenuItem<int>).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
});

  testWidgets('Registration without filled form', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegisterScreen(),
      ),
    );

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsNWidgets(2));
    expect(find.text('E-mail is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Select your age'), findsOneWidget);
    expect(find.text('Select your country'), findsOneWidget);
    expect(find.text('Password confirmation is required'), findsOneWidget);
  });

  testWidgets('Registration with different passwords', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RegisterScreen(),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(4), 'password123');
    await tester.enterText(find.byType(TextFormField).at(5), '321drowddap');

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords must be the same'), findsOneWidget);
  });
}
