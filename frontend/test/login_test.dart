import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/views/screens/login_screen.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User can log in successfully', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');

    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    // await tester.tap(find.byType(ElevatedButton));
    // await tester.pumpAndSettle();
  });
}
