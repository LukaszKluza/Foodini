import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/views/screens/register_screen.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../mocks/mocks.mocks.dart';

final client = MockClient();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Register screen elements are displayed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: RegisterScreen()));

    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);

    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Register button triggers registration process', (
    WidgetTester tester,
  ) async {
    when(
      client.post(any, headers: anyNamed("headers"), body: anyNamed("body")),
    ).thenAnswer(
      (_) async => http.Response(jsonEncode({"message": "OK"}), 200),
    );

    final goRouter = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => RegisterScreen()),
        GoRoute(
          path: '/home',
          builder: (context, state) => Scaffold(body: Text('Home Screen')),
        ),
      ],
    );

    await tester.pumpWidget(
      Provider<ApiClient>.value(
        value: ApiClient(client),
        child: MaterialApp.router(routerConfig: goRouter),
      ),
    );

    await tester.enterText(find.byKey(Key(AppConfig.firstName)), 'John');
    await tester.enterText(find.byKey(Key(AppConfig.lastName)), 'Doe');
    await tester.enterText(
      find.byKey(Key(AppConfig.email)),
      'john@example.com',
    );
    await tester.enterText(find.byKey(Key(AppConfig.password)), 'password123');
    await tester.enterText(
      find.byKey(Key(AppConfig.confirmPassword)),
      'password123',
    );

    await tester.tap(find.byKey(Key(AppConfig.age)));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownMenuItem<int>).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key(AppConfig.register)));
    await tester.pumpAndSettle();
  });

  testWidgets('Registration without filled form', (WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<ApiClient>.value(
        value: ApiClient(client),
        child: MaterialApp(home: RegisterScreen()),
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

  testWidgets('Registration with different passwords', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      Provider<ApiClient>.value(
        value: ApiClient(client),
        child: MaterialApp(home: RegisterScreen()),
      ),
    );

    await tester.enterText(find.byKey(Key(AppConfig.password)), 'password123');
    await tester.enterText(
      find.byKey(Key(AppConfig.confirmPassword)),
      '321drowddap',
    );

    await tester.tap(find.byKey(Key(AppConfig.register)));
    await tester.pumpAndSettle();

    expect(find.text('Passwords must be the same'), findsOneWidget);
  });
}
