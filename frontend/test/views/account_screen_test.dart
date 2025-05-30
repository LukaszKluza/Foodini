import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/models/user_response.dart';
import 'package:frontend/repository/user_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:frontend/blocs/account_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/account_states.dart';
import 'package:frontend/views/screens/account_screen.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';

import '../mocks/mocks.mocks.dart';

late MockDio mockDio;
late AccountBloc accountBloc;
late MockApiClient mockApiClient;
late AuthRepository authRepository;
late UserStorage userStorage;
late MockTokenStorageRepository mockTokenStorageRepository;

Widget wrapWithProviders(Widget child, {List<GoRoute> routes = const []}) {
  final goRouter = GoRouter(
    initialLocation: '/',
    routes: [GoRoute(path: '/', builder: (context, state) => child), ...routes],
  );

  return MultiProvider(
    providers: [
      Provider<AuthRepository>.value(value: authRepository),
      Provider<TokenStorageRepository>.value(value: mockTokenStorageRepository),
    ],
    child: MaterialApp.router(routerConfig: goRouter),
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

  tearDown(() {
    accountBloc.close();
  });

  testWidgets('Account screen shows all buttons and navbar', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(
      wrapWithProviders(AccountScreen(bloc: accountBloc)),
    );

    // When
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.changePassword), findsOneWidget);
    expect(find.text(AppConfig.logout), findsOneWidget);
    expect(find.text(AppConfig.deleteAccount), findsOneWidget);
    expect(find.text(AppConfig.myAccount), findsOneWidget);
    expect(find.byType(BottomNavBar), findsOneWidget);
    expect(accountBloc.state, isA<AccountInitial>());
  });

  testWidgets('Tap on Change password navigates to form', (tester) async {
    // Given
    final goRouter = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => AccountScreen(bloc: accountBloc),
        ),
        GoRoute(
          path: '/provide_email',
          builder:
              (context, state) => const Scaffold(
                key: Key(AppConfig.changePassword),
                body: Center(child: Text('Change Password Screen')),
              ),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: authRepository),
          Provider<TokenStorageRepository>.value(
            value: mockTokenStorageRepository,
          ),
        ],
        child: MaterialApp.router(routerConfig: goRouter),
      ),
    );

    await tester.pumpAndSettle();

    // When
    await tester.tap(find.text(AppConfig.changePassword));
    await tester.pumpAndSettle();

    // Then
    expect(find.byKey(const Key(AppConfig.changePassword)), findsOneWidget);
    expect(find.text('Change Password Screen'), findsOneWidget);
  });

  testWidgets('User can log out successfully', (WidgetTester tester) async {
    // Given
    when(mockApiClient.logout(1)).thenAnswer(
      (_) async => Response<dynamic>(
        statusCode: 204,
        requestOptions: RequestOptions(path: Endpoints.logout),
      ),
    );

    UserStorage().setUser(UserResponse(id: 1, email: "jan4@example.com"));

    final goRouter = GoRouter(
      initialLocation: '/account',
      routes: [
        GoRoute(
          path: '/account',
          builder: (context, state) => AccountScreen(bloc: accountBloc),
        ),
        GoRoute(
          path: '/',
          builder:
              (context, state) =>
                  Scaffold(body: Center(child: Text(AppConfig.homePage))),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: authRepository),
          Provider<TokenStorageRepository>.value(
            value: mockTokenStorageRepository,
          ),
        ],
        child: MaterialApp.router(routerConfig: goRouter),
      ),
    );

    await tester.pumpAndSettle();

    expect(accountBloc.state, isA<AccountInitial>());

    // When
    await tester.tap(find.text(AppConfig.logout));
    await tester.pump();

    expect(accountBloc.state, isA<AccountLogoutSuccess>());

    await tester.pump(const Duration(milliseconds: Constants.redirectionDelay));
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.successfullyLoggedOut), findsOneWidget);
    expect(find.text(AppConfig.homePage), findsOneWidget);
  });

  testWidgets('User can successfully delete account', (
    WidgetTester tester,
  ) async {
    // Given
    when(mockApiClient.delete(1)).thenAnswer(
      (_) async => Response<dynamic>(
        statusCode: 204,
        requestOptions: RequestOptions(path: AppConfig.delete),
      ),
    );

    UserStorage().setUser(UserResponse(id: 1, email: "jan4@example.com"));

    final goRouter = GoRouter(
      initialLocation: '/account',
      routes: [
        GoRoute(
          path: '/account',
          builder: (context, state) => AccountScreen(bloc: accountBloc),
        ),
        GoRoute(
          path: '/',
          builder:
              (context, state) =>
                  Scaffold(body: Center(child: Text(AppConfig.homePage))),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: authRepository),
          Provider<TokenStorageRepository>.value(
            value: mockTokenStorageRepository,
          ),
        ],
        child: MaterialApp.router(routerConfig: goRouter),
      ),
    );

    await tester.pumpAndSettle();

    expect(accountBloc.state, isA<AccountInitial>());

    // When
    await tester.tap(find.text(AppConfig.deleteAccount));
    await tester.pump();

    await tester.tap(find.text(AppConfig.delete));
    await tester.pump();

    expect(accountBloc.state, isA<AccountDeleteSuccess>());

    await tester.pump(const Duration(milliseconds: Constants.redirectionDelay));
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.successfullyDeletedAccount), findsOneWidget);
    expect(find.text(AppConfig.homePage), findsOneWidget);
  });

  testWidgets('User close delete account pop-up', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(
      wrapWithProviders(AccountScreen(bloc: accountBloc)),
    );

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
    expect(find.text(AppConfig.myAccount), findsOneWidget);
    expect(find.byType(BottomNavBar), findsOneWidget);
  });
}
