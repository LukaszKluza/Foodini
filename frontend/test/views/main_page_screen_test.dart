import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/views/screens/main_page_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Main page shows all buttons', (tester) async {
    await tester.pumpWidget(MaterialApp(home: MainPageScreen()));

    expect(find.text(AppConfig.myAccout), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('Tap on My Account navigates to account screen', (tester) async {
    final goRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => MainPageScreen(),
        ),
        GoRoute(
          path: '/account',
          builder: (context, state) =>
              const Scaffold(key: Key(AppConfig.myAccout)),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppConfig.myAccout));
    await tester.pumpAndSettle();

    expect(find.byKey(Key(AppConfig.myAccout)), findsOneWidget);
  });
}
