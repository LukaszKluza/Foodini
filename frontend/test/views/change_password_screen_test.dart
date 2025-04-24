import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:frontend/views/screens/change_password_screen.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import '../mocks/mocks.mocks.dart';

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

  testWidgets('ChangePassword screen shows all fields and button', (tester) async {
    // Given, When
    await tester.pumpWidget(wrapWithProviders(ChangePasswordScreen()));

    // Then
    expect(find.byKey(Key(AppConfig.email)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.newPassword)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.confirmPassword)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.changePassword)), findsOneWidget);
  });

  testWidgets('Submit without filling form shows validation errors', (tester) async {
    // Given, When
    await tester.pumpWidget(wrapWithProviders(ChangePasswordScreen()));
    await tester.tap(find.byKey(Key(AppConfig.changePassword)));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('E-mail is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Password confirmation is required'), findsOneWidget);
  });

  testWidgets('Mismatched passwords show validation error', (tester) async {
    // Given
    await tester.pumpWidget(wrapWithProviders(ChangePasswordScreen()));

    // When
    await tester.enterText(find.byKey(Key(AppConfig.email)), 'test@example.com');
    await tester.enterText(find.byKey(Key(AppConfig.newPassword)), 'password123');
    await tester.enterText(find.byKey(Key(AppConfig.confirmPassword)), '321drowssap');

    await tester.tap(find.byKey(Key(AppConfig.changePassword)));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Passwords must be the same'), findsOneWidget);
  });
}
