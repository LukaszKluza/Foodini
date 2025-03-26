import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/views/screens/register_screen.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User can register', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: RegisterScreen()));

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'John');
    await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'john@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');
    await tester.enterText(find.byType(TextFormField).at(4), 'password123');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Registered successfully'), findsOneWidget);
  });
}
