import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/language.dart';
import 'package:frontend/models/user_response.dart';
import 'package:frontend/repository/user_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:frontend/blocs/account_bloc.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
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
      Provider<TokenStorageRepository>.value(value: mockTokenStorageRepository),
    ],
    child: MaterialApp(
      home: child,
      locale: Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
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
    await tester.pumpWidget(
      wrapWithProviders(AccountScreen(bloc: accountBloc)),
    );

    // When
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Change password'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
    expect(find.text('Foodini'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(accountBloc.state, isA<AccountInitial>());
  });

  testWidgets('Tap on Change password navigates to form', (tester) async {
    // Given
    final goRouter = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => AccountScreen()),
        GoRoute(
          path: '/provide_email',
          builder:
              (context, state) => const Scaffold(key: Key('change_password')),
        ),
      ],
    );

    // When
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: authRepository),
          Provider<TokenStorageRepository>.value(
            value: mockTokenStorageRepository,
          ),
        ],
        child: MaterialApp.router(
          routerConfig: goRouter,
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.tap(find.text('Change password'));
    await tester.pumpAndSettle();

    // Then
    expect(find.byKey(Key('change_password')), findsOneWidget);
  });

  testWidgets('User can log out successfully', (WidgetTester tester) async {
    // Given
    when(mockApiClient.logout(1)).thenAnswer(
      (_) async => Response<dynamic>(
        statusCode: 204,
        requestOptions: RequestOptions(path: Endpoints.logout),
      ),
    );

    UserStorage().setUser(
      UserResponse(id: 1, language: Language.en, email: 'jan4@example.com'),
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
          builder: (context, state) => Scaffold(body: Text('Home page')),
        ),
      ],
    );

    // When
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: authRepository),
          Provider<TokenStorageRepository>.value(
            value: mockTokenStorageRepository,
          ),
        ],
        child: MaterialApp.router(
          routerConfig: goRouter,
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(accountBloc.state, isA<AccountInitial>());

    await tester.tap(find.text('Logout'));
    await tester.pump();

    expect(accountBloc.state, isA<AccountLogoutSuccess>());

    await tester.pump(const Duration(milliseconds: Constants.redirectionDelay));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Account logged out successfully'), findsOneWidget);
    expect(find.text('Home page'), findsOneWidget);
  });

  testWidgets('User can successfully delete account', (
    WidgetTester tester,
  ) async {
    // Given
    when(mockApiClient.delete(1)).thenAnswer(
      (_) async => Response<dynamic>(
        statusCode: 204,
        requestOptions: RequestOptions(path: 'Delete'),
      ),
    );

    UserStorage().setUser(
      UserResponse(id: 1, language: Language.pl, email: 'jan4@example.com'),
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
          builder: (context, state) => Scaffold(body: Text('Home page')),
        ),
      ],
    );

    // When
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: authRepository),
          Provider<TokenStorageRepository>.value(
            value: mockTokenStorageRepository,
          ),
        ],
        child: MaterialApp.router(
          routerConfig: goRouter,
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(accountBloc.state, isA<AccountInitial>());

    await tester.tap(find.text('Delete account'));
    await tester.pump();

    await tester.tap(find.text('Delete'));
    await tester.pump();

    expect(accountBloc.state, isA<AccountDeleteSuccess>());

    await tester.pump(const Duration(milliseconds: Constants.redirectionDelay));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Account deleted successfully'), findsOneWidget);
    expect(find.text('Home page'), findsOneWidget);
  });

  testWidgets('User close delete account pop-up', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(
      wrapWithProviders(AccountScreen(bloc: accountBloc)),
    );

    // When
    await tester.pumpAndSettle();

    expect(accountBloc.state, isA<AccountInitial>());

    await tester.tap(find.text('Delete account'));
    await tester.pump();

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    // Then
    verifyZeroInteractions(mockDio);
    verifyZeroInteractions(mockApiClient);
    verifyZeroInteractions(mockTokenStorageRepository);
    expect(accountBloc.state, isA<AccountInitial>());
    expect(find.text('Delete account'), findsOneWidget);
    expect(find.text('Foodini'), findsOneWidget);
  });
}
