import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blocs/user/account_bloc.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/models/user/user_response.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/views/screens/user/account_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/account_states.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';

import '../mocks/mocks.mocks.dart';

late MockDio mockDio;
late AccountBloc accountBloc;
late MockApiClient mockApiClient;
late AuthRepository authRepository;
late UserStorage userStorage;
late MockTokenStorageRepository mockTokenStorageRepository;

Widget wrapWithProviders(Widget child, {String initialRoute = '/'}) {
  final goRouter = GoRouter(
    initialLocation: initialRoute,
    routes: [
      GoRoute(
        path: '/',
        builder:
            (_, __) => Scaffold(
              body: Center(
                child: Text('Home page', key: const Key('home_page')),
              ),
            ),
      ),
      GoRoute(path: '/account', builder: (_, __) => child),
      GoRoute(
        path: '/provide_email',
        builder: (_, __) => const Scaffold(key: Key('change_password')),
      ),
    ],
  );

  return MultiProvider(
    providers: [
      Provider<AuthRepository>.value(value: authRepository),
      Provider<TokenStorageRepository>.value(value: mockTokenStorageRepository),
    ],
    child: MaterialApp.router(
      routerConfig: goRouter,
      locale: const Locale('en'),
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

  tearDown(() {
    accountBloc.close();
  });

  testWidgets('Account screen shows all buttons and navbar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(
        AccountScreen(bloc: accountBloc),
        initialRoute: '/account',
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Change password'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);
    expect(find.text('Foodini'), findsOneWidget);
    expect(find.byType(BottomNavBar), findsOneWidget);
    expect(accountBloc.state, isA<AccountInitial>());
  });

  testWidgets('Tap on Change password navigates to form', (tester) async {
    await tester.pumpWidget(
      wrapWithProviders(
        AccountScreen(bloc: accountBloc),
        initialRoute: '/account',
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text("Change password"));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key("change_password")), findsOneWidget);
  });

  testWidgets('User can log out successfully', (WidgetTester tester) async {
    when(mockApiClient.logout(1)).thenAnswer(
      (_) async => Response<dynamic>(
        statusCode: 204,
        requestOptions: RequestOptions(path: Endpoints.logout),
      ),
    );

    UserStorage().setUser(
      UserResponse(id: 1, email: "jan4@example.com", language: Language.en),
    );

    await tester.pumpWidget(
      wrapWithProviders(
        AccountScreen(bloc: accountBloc),
        initialRoute: '/account',
      ),
    );

    await tester.pumpAndSettle();
    expect(accountBloc.state, isA<AccountInitial>());

    await tester.tap(find.text("Logout"));
    await tester.pump();
    expect(accountBloc.state, isA<AccountLogoutSuccess>());

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Account logged out successfully'), findsOneWidget);
    expect(find.byKey(const Key('home_page')), findsOneWidget);
  });

  testWidgets('User can successfully delete account', (
    WidgetTester tester,
  ) async {
    when(mockApiClient.delete(1)).thenAnswer(
      (_) async => Response<dynamic>(
        statusCode: 204,
        requestOptions: RequestOptions(path: "Delete"),
      ),
    );

    UserStorage().setUser(
      UserResponse(id: 1, email: "jan4@example.com", language: Language.en),
    );

    await tester.pumpWidget(
      wrapWithProviders(
        AccountScreen(bloc: accountBloc),
        initialRoute: '/account',
      ),
    );

    await tester.pumpAndSettle();
    expect(accountBloc.state, isA<AccountInitial>());

    await tester.tap(find.text("Delete account"));
    await tester.pump();
    await tester.tap(find.text("Delete"));
    await tester.pump();
    expect(accountBloc.state, isA<AccountDeleteSuccess>());

    await tester.pump(const Duration(milliseconds: Constants.redirectionDelay));
    await tester.pumpAndSettle();

    expect(find.text('Account deleted successfully'), findsOneWidget);
    expect(find.byKey(const Key('home_page')), findsOneWidget);
  });

  testWidgets('User close delete account pop-up', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrapWithProviders(
        AccountScreen(bloc: accountBloc),
        initialRoute: '/account',
      ),
    );

    await tester.pumpAndSettle();
    expect(accountBloc.state, isA<AccountInitial>());

    await tester.tap(find.text("Delete account"));
    await tester.pump();
    await tester.tap(find.text("Cancel"));
    await tester.pump();

    verifyZeroInteractions(mockDio);
    verifyZeroInteractions(mockApiClient);
    verifyZeroInteractions(mockTokenStorageRepository);
    expect(accountBloc.state, isA<AccountInitial>());
    expect(find.text("Delete account"), findsOneWidget);
    expect(find.text("Foodini"), findsOneWidget);
    expect(find.byType(BottomNavBar), findsOneWidget);
  });
}
