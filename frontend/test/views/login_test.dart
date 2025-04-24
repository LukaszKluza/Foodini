import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:frontend/views/screens/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../mocks/mocks.mocks.dart';
import 'package:dio/dio.dart';

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

  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    when(mockDio.interceptors).thenReturn(Interceptors());
  });

  testWidgets('Login screen elements are displayed', (WidgetTester tester) async {
    // Given, When
    await tester.pumpWidget(wrapWithProviders(LoginScreen()));

    // Then
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(TextButton), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('User can log in successfully', (WidgetTester tester) async {
    // Given
    final response = Response(
      requestOptions: RequestOptions(path: AppConfig.loginUrl),
      data: {
        "id": 47,
        "email": "jan4@example.com",
        "access_token": "access_token",
        "refresh_token": "refresh_token",
      },
      statusCode: 200,
    );

    final goRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => Scaffold(body: Text('Home Screen')),
        ),
      ],
    );

    // When
    await tester.pumpWidget(wrapWithProviders(MaterialApp.router(routerConfig: goRouter)));

    when(mockDio.post(
      AppConfig.loginUrl,
      data: anyNamed("data"),
      options: anyNamed("options"),
    )).thenAnswer((_) async => response);

    // Then
    await tester.enterText(find.byKey(Key(AppConfig.email)), 'jan4@example.com');
    await tester.enterText(find.byKey(Key(AppConfig.password)), 'password123');
    await tester.tap(find.byKey(Key(AppConfig.login)));
    await tester.pumpAndSettle();
  });

  testWidgets('Login with missing email and password', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(wrapWithProviders(LoginScreen()));

    // When
    await tester.tap(find.byKey(Key(AppConfig.login)));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('E-mail is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}