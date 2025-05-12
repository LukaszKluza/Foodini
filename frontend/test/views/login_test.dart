import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:frontend/blocs/login_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:frontend/states/login_states.dart';
import 'package:frontend/views/screens/login_screen.dart';

import '../mocks/mocks.mocks.dart';

late MockDio mockDio;
late LoginBloc loginBloc;
late MockApiClient mockApiClient;
late AuthRepository authRepository;
late MockTokenStorageRepository mockTokenStorageRepository;

Widget wrapWithProviders(Widget child) {
  return MultiProvider(
    providers: [
      Provider<AuthRepository>.value(value: authRepository),
      Provider<TokenStorageRepository>.value(value: mockTokenStorageRepository)
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockDio = MockDio();
    mockApiClient = MockApiClient();
    authRepository = AuthRepository(mockApiClient);
    mockTokenStorageRepository = MockTokenStorageRepository();
    loginBloc = LoginBloc(authRepository, mockTokenStorageRepository);
    when(mockDio.interceptors).thenReturn(Interceptors());
  });

  testWidgets('Login screen elements are displayed', (WidgetTester tester) async {
    // Given, When
    await tester.pumpWidget(wrapWithProviders(LoginScreen(bloc: loginBloc)));

    // Then
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(TextButton), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);

    expect(loginBloc.state, isA<LoginInitial>());
  });

  testWidgets('User can log in successfully', (WidgetTester tester) async {
    // Given
    when(mockApiClient.login(any)).thenAnswer(
          (_) async => Response<dynamic>(
        data: {
          "id": 1,
          "email": "jan4@example.com",
          "access_token": "access_token",
          "refresh_token": "refresh_token",
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: AppConfig.registerUrl),
      ),
    );

    final goRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => LoginScreen(bloc: loginBloc),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => Scaffold(body: Text('Home Screen')),
        ),
      ],
    );

    // When
    await tester.pumpWidget(wrapWithProviders(MaterialApp.router(routerConfig: goRouter)));

    // Then
    await tester.enterText(find.byKey(Key(AppConfig.email)), 'jan4@example.com');
    await tester.enterText(find.byKey(Key(AppConfig.password)), 'Password1234');

    expect(loginBloc.state, isA<LoginInitial>());

    await tester.tap(find.byKey(Key(AppConfig.login)));
    await tester.pumpAndSettle();

    expect(loginBloc.state, isA<LoginSuccess>());
  });

  testWidgets('Login with missing email and password', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(wrapWithProviders(LoginScreen(bloc: loginBloc)));

    // When
    await tester.tap(find.byKey(Key(AppConfig.login)));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('E-mail is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}