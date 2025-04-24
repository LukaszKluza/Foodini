import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:frontend/views/screens/change_password_screen.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'mocks/mocks.mocks.dart';

Widget wrapWithProviders(Widget child) {
  final mockAuthRepository = MockAuthRepository();
  final mockTokenStorageRepository = MockTokenStorageRepository();

  return MultiProvider(
    providers: [
      Provider<AuthRepository>.value(value: mockAuthRepository),
      Provider<TokenStorageRepository>.value(value: mockTokenStorageRepository)
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ChangePassword screen shows all fields and button', (
    tester,
  ) async {
    await tester.pumpWidget(wrapWithProviders(ChangePasswordScreen()));
    expect(find.byKey(Key(AppConfig.email)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.newPassword)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.confirmPassword)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.changePassword)), findsOneWidget);
  });

  testWidgets('Submit without filling form shows validation errors', (
    tester,
  ) async {
    await tester.pumpWidget(wrapWithProviders(ChangePasswordScreen()));
    await tester.tap(find.byKey(Key(AppConfig.changePassword)));
    await tester.pumpAndSettle();

    expect(find.text(AppConfig.requiredEmail), findsOneWidget);
    expect(find.text(AppConfig.requiredPassword), findsOneWidget);
    expect(find.text(AppConfig.requiredPasswordConfirmation), findsOneWidget);
  });

  testWidgets('Mismatched passwords show validation error', (tester) async {
    await tester.pumpWidget(wrapWithProviders(ChangePasswordScreen()));
    await tester.enterText(
      find.byKey(Key(AppConfig.email)),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(Key(AppConfig.newPassword)),
      'Password123',
    );
    await tester.enterText(
      find.byKey(Key(AppConfig.confirmPassword)),
      '321drowssaP',
    );
    await tester.tap(find.byKey(Key(AppConfig.changePassword)));
    await tester.pumpAndSettle();

    expect(find.text(AppConfig.samePasswords), findsOneWidget);
  });
}
