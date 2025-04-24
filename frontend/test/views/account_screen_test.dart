import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:frontend/views/screens/account_screen.dart';
import 'package:go_router/go_router.dart';
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

  testWidgets('Account screen shows all buttons', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(wrapWithProviders(AccountScreen()));

    // When
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.changePassword), findsOneWidget);
    expect(find.text(AppConfig.logout), findsOneWidget);
  });

  testWidgets('Tap on Change password navigates to form', (tester) async {
    // Given
    final goRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => AccountScreen(),
        ),
        GoRoute(
          path: '/change_password',
          builder:
              (context, state) =>
                  const Scaffold(key: Key(AppConfig.changePassword)),
        ),
      ],
    );

    // When
    await tester.pumpWidget(wrapWithProviders(MaterialApp.router(routerConfig: goRouter)));
    await tester.tap(find.text(AppConfig.changePassword));
    await tester.pumpAndSettle();

    // Then
    expect(find.byKey(Key(AppConfig.changePassword)), findsOneWidget);
  });

  testWidgets('User can log out successfully', (WidgetTester tester) async {
    // Given
    final goRouter = GoRouter(
      initialLocation: '/account',
      routes: [
        GoRoute(
          path: '/account',
          builder: (context, state) => AccountScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(body: Text(AppConfig.homePage)),
        ),
      ],
    );

    // When
    await tester.pumpWidget(wrapWithProviders(MaterialApp.router(routerConfig: goRouter)));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppConfig.logout));
    await tester.pump(); 

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.successfullyLoggedOut), findsOneWidget);
    expect(find.text(AppConfig.homePage), findsOneWidget);
  });
}
