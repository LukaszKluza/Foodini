import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/views/screens/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login screen elements are displayed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(TextButton), findsNWidgets(2));

    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('User can log in successfully', (WidgetTester tester) async {
    final client = MockClient();

    when(
      client.post(any, headers: anyNamed("headers"), body: anyNamed("body")),
    ).thenAnswer(
      (_) async => http.Response(
        jsonEncode({
          "id": 47,
          "email": "jan4@example.com",
          "access_token": "access_token",
          "refresh_token": "refresh_token",
        }),
        200,
      ),
    );

    final goRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => LoginScreen(client: client),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => Scaffold(body: Text('Home Screen')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));

    await tester.enterText(
      find.byKey(Key(AppConfig.email)),
      'test@example.com',
    );
    await tester.enterText(find.byKey(Key(AppConfig.password)), 'password123');

    await tester.tap(find.byKey(Key(AppConfig.login)));

    await tester.pumpAndSettle();
  });

  testWidgets('Login with different passwords', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    await tester.tap(find.byKey(Key(AppConfig.login)));
    await tester.pumpAndSettle();

    expect(find.text('E-mail is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}
