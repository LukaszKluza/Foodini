import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/events/login_events.dart';
import 'package:frontend/models/user_response.dart';
import 'package:frontend/repository/user_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:frontend/blocs/login_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
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
    UserStorage().setUser(
        UserResponse(
          id: 1,
          email: "jan4@example.com",
        )
    );

    when(mockApiClient.login(any)).thenAnswer(
          (_) async => Response<dynamic>(
        data: {
          "id": 1,
          "email": "jan4@example.com",
          "access_token": "access_token",
          "refresh_token": "refresh_token",
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: AppConfig.loginUrl),
      ),
    );

    when(mockApiClient.getUser()).thenAnswer(
          (_) async => Response<dynamic>(
        data: {"id": 1, "email": "jan4@example.com"},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/user'),
      ),
    );

    final goRouter = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(bloc: loginBloc),
        ),
        GoRoute(
          path: '/main_page',
          builder: (context, state) => Scaffold(body: Text(AppConfig.foodini)),
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

    await tester.pump(const Duration(milliseconds: AppConfig.redirectionDelay));
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.foodini), findsOneWidget);

    var loggedUser = UserStorage().getUser;
    expect(loggedUser, isNotNull);
    expect(loggedUser?.id, 1);
    expect(loggedUser?.email, 'jan4@example.com');
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

  testWidgets('Login with missing unverified account', (WidgetTester tester) async {
    // Given
    when(mockApiClient.login(any)).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: AppConfig.loginUrl),
        response: Response(
          requestOptions: RequestOptions(path: AppConfig.loginUrl),
          statusCode: 403,
          data: {
            "detail": "EMAIL_NOT_VERIFIED",
          },
        ),
      ),
    );

    when(mockApiClient.resendVerificationMail(any)).thenAnswer(
          (_) async => Response<dynamic>(
        statusCode: 204,
        requestOptions: RequestOptions(path: '/users/confirm/resend-verification-new-account'),
      ),
    );

    final goRouter = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(bloc: loginBloc),
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

    expect(loginBloc.state, isA<AccountNotVerified>());

    expect(find.text('Your account has not been confirmed.'), findsOneWidget);
    expect(find.text('Send verification email again'), findsOneWidget);

    await tester.tap(find.byKey(Key(AppConfig.sendVerificationEmailAgain)));
    await tester.pumpAndSettle();

    expect(loginBloc.state, isA<ResendAccountVerificationSuccess>());
    expect(find.text('Email account verification send successfully'), findsOneWidget);
  });

  testWidgets('Properly message after successful account verification', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(wrapWithProviders(LoginScreen(bloc: loginBloc)));

    // When
    loginBloc.add(InitFromUrl("success"));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Account has been activated successfully'), findsOneWidget);
  });

  testWidgets('Properly message when account has not been confirmed', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(wrapWithProviders(LoginScreen(bloc: loginBloc)));

    // When
    loginBloc.add(InitFromUrl("error"));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Your account has not been confirmed.'), findsOneWidget);
    expect(find.text('Send verification email again'), findsOneWidget);
  });
}