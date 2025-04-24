import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/views/screens/main_page_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Main page shows all buttons', (tester) async {
    // Given, When
    await tester.pumpWidget(MaterialApp(home: MainPageScreen()));

    // Then
    expect(find.text(AppConfig.myAccount), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('Tap on My Account navigates to account screen', (tester) async {
    // Given
    final goRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MainPageScreen(),
        ),
        GoRoute(
          path: '/account',
          builder: (context, state) =>
              const Scaffold(key: Key(AppConfig.myAccount)),
        ),
      ],
    );

    // When
    await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppConfig.myAccount));
    await tester.pumpAndSettle();

    // Then
    expect(find.byKey(Key(AppConfig.myAccount)), findsOneWidget);
  });
}
