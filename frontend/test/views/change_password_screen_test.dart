import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/views/screens/change_password_screen.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import '../mocks/mocks.mocks.dart';

final client = MockClient();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ChangePassword screen shows all fields and button', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ChangePasswordScreen()));

    expect(find.byKey(Key(AppConfig.email)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.newPassword)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.confirmPassword)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.changePassword)), findsOneWidget);
  });

  testWidgets('Submit without filling form shows validation errors', (tester) async {
    await tester.pumpWidget(
      Provider<ApiClient>.value(
        value: ApiClient(client),
        child: MaterialApp(home: ChangePasswordScreen()),
      ),
    );

    await tester.tap(find.byKey(Key(AppConfig.changePassword)));
    await tester.pumpAndSettle();

    expect(find.text('E-mail is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Password confirmation is required'), findsOneWidget);
  });

  testWidgets('Mismatched passwords show validation error', (tester) async {
    await tester.pumpWidget(
      Provider<ApiClient>.value(
        value: ApiClient(client),
        child: MaterialApp(home: ChangePasswordScreen()),
      ),
    );

    await tester.enterText(find.byKey(Key(AppConfig.email)), 'test@example.com');
    await tester.enterText(find.byKey(Key(AppConfig.newPassword)), 'password123');
    await tester.enterText(find.byKey(Key(AppConfig.confirmPassword)), '321drowssap');

    await tester.tap(find.byKey(Key(AppConfig.changePassword)));
    await tester.pumpAndSettle();

    expect(find.text('Passwords must be the same'), findsOneWidget);
  });
}
