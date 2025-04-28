import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/logged_user.dart';
import 'package:frontend/repository/user_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:frontend/blocs/account_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:frontend/states/account_states.dart';
import 'package:frontend/views/screens/account_screen.dart';

import '../mocks/mocks.mocks.dart';

late MockDio mockDio;
late AccountBloc accountBloc;
late MockApiClient mockApiClient;
late AuthRepository authRepository;
late UserStorage userStorage;
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
    userStorage = UserStorage();
    authRepository = AuthRepository(mockApiClient);
    mockTokenStorageRepository = MockTokenStorageRepository();
    accountBloc = AccountBloc(authRepository, mockTokenStorageRepository);
    when(mockDio.interceptors).thenReturn(Interceptors());
  });

  testWidgets('Account screen shows all buttons', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(wrapWithProviders(AccountScreen(bloc: accountBloc)));

    // When
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.changePassword), findsOneWidget);
    expect(find.text(AppConfig.logout), findsOneWidget);
    expect(find.text(AppConfig.deleteAccount), findsOneWidget);
    expect(accountBloc.state, isA<AccountInitial>());
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
    when(mockApiClient.logout(1)).thenAnswer(
          (_) async => Response<dynamic>(
        statusCode: 204,
        requestOptions: RequestOptions(path: AppConfig.logoutUrl),
      ),
    );

    UserStorage().setUser(
        LoggedUser(
            id: 1,
            email: "jan4@example.com",
            accessToken: "accessToken",
            refreshToken: "refreshToken"
        )
    );

    final goRouter = GoRouter(
      initialLocation: '/account',
      routes: [
        GoRoute(
          path: '/account',
          builder: (context, state) => AccountScreen(bloc: accountBloc),
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

    expect(accountBloc.state, isA<AccountInitial>());

    await tester.tap(find.text(AppConfig.logout));
    await tester.pump();

    expect(accountBloc.state, isA<AccountLogoutSuccess>());

    await tester.pump(const Duration(milliseconds: AppConfig.redirectionDelay));
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.successfullyLoggedOut), findsOneWidget);
    expect(find.text(AppConfig.homePage), findsOneWidget);
  });

  testWidgets('User can successfully delete account', (WidgetTester tester) async {
    // Given
    when(mockApiClient.delete(1)).thenAnswer(
          (_) async => Response<dynamic>(
        statusCode: 204,
        requestOptions: RequestOptions(path: AppConfig.delete),
      ),
    );

    UserStorage().setUser(
        LoggedUser(
            id: 1,
            email: "jan4@example.com",
            accessToken: "accessToken",
            refreshToken: "refreshToken"
        )
    );

    final goRouter = GoRouter(
      initialLocation: '/account',
      routes: [
        GoRoute(
          path: '/account',
          builder: (context, state) => AccountScreen(bloc: accountBloc),
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

    expect(accountBloc.state, isA<AccountInitial>());

    await tester.tap(find.text(AppConfig.deleteAccount));
    await tester.pump();

    await tester.tap(find.text(AppConfig.delete));
    await tester.pump();

    expect(accountBloc.state, isA<AccountDeleteSuccess>());

    await tester.pump(const Duration(milliseconds: AppConfig.redirectionDelay));
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.successfullyDeletedAccount), findsOneWidget);
    expect(find.text(AppConfig.homePage), findsOneWidget);
  });

  testWidgets('User close delete account pop-up', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(wrapWithProviders(AccountScreen(bloc: accountBloc)));

    // When
    await tester.pumpAndSettle();

    expect(accountBloc.state, isA<AccountInitial>());

    await tester.tap(find.text(AppConfig.deleteAccount));
    await tester.pump();

    await tester.tap(find.text(AppConfig.cancel));
    await tester.pump();

    // Then
    verifyZeroInteractions(mockDio);
    verifyZeroInteractions(mockApiClient);
    verifyZeroInteractions(mockTokenStorageRepository);
    expect(accountBloc.state, isA<AccountInitial>());
    expect(find.text(AppConfig.deleteAccount), findsOneWidget);
    expect(find.text(AppConfig.foodini), findsOneWidget);
  });
}
