import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blocs/user/account_bloc.dart';
import 'package:frontend/blocs/user/register_bloc.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/foodini.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/register_states.dart';
import 'package:frontend/views/screens/user/register_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../mocks/mocks.mocks.dart';

late MockDio mockDio;
late RegisterBloc registerBloc;
late MockApiClient mockApiClient;
late UserRepository authRepository;
late MockLanguageCubit mockLanguageCubit;
late MockTokenStorageRepository mockTokenStorageRepository;

Widget wrapWithProviders(
  Widget child, {
  List<Provider<dynamic>> additionalProviders = const [],
}) {
  return MultiProvider(
    providers: [
      Provider<UserRepository>.value(value: authRepository),
      Provider<TokenStorageRepository>.value(value: mockTokenStorageRepository),
      ...additionalProviders,
    ],
    child: MaterialApp(
      home: child,
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
    mockLanguageCubit = MockLanguageCubit();
    authRepository = UserRepository(mockApiClient);
    registerBloc = RegisterBloc(authRepository);
    mockTokenStorageRepository = MockTokenStorageRepository();
    when(mockDio.interceptors).thenReturn(Interceptors());
  });

  testWidgets('Register screen elements are displayed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrapWithProviders(RegisterScreen()));

    expect(find.byIcon(Icons.translate_rounded), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Registration'), findsOneWidget);
  });

  testWidgets('Register form submits with valid data', (
    WidgetTester tester,
  ) async {
    when(mockApiClient.register(any)).thenAnswer(
      (_) async => Response<dynamic>(
        data: {
          'id': 1,
          'email': 'jan4@example.com',
          'name': 'Jan',
          'language': 'pl',
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: Endpoints.register),
      ),
    );

    final goRouter = GoRouter(
      initialLocation: '/register',
      routes: [
        GoRoute(
          path: '/register',
          builder: (context, state) => RegisterScreen(bloc: registerBloc),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => Scaffold(body: Text('Login')),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<UserRepository>.value(value: authRepository),
          Provider<TokenStorageRepository>.value(
            value: mockTokenStorageRepository,
          ),
        ],
        child: MaterialApp.router(
          routerConfig: goRouter,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(Key('first_name')), 'John');
    await tester.enterText(find.byKey(Key('last_name')), 'Doe');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('country')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Argentina'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(Key('e-mail')), 'john@example.com');
    await tester.enterText(find.byKey(Key('password')), 'Password1234');
    await tester.enterText(find.byKey(Key('confirm_password')), 'Password1234');

    expect(registerBloc.state, isA<RegisterInitial>());

    await tester.tap(find.byKey(Key('register')));
    await tester.pumpAndSettle();

    expect(registerBloc.state, isA<RegisterSuccess>());

    await tester.pump(const Duration(milliseconds: Constants.redirectionDelay));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Registration without filled form', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithProviders(RegisterScreen()));

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsNWidgets(2));
    expect(find.text('E-mail is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Select your country'), findsOneWidget);
    expect(find.text('Password confirmation is required'), findsOneWidget);
  });

  testWidgets('Registration with different passwords', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrapWithProviders(RegisterScreen()));

    await tester.enterText(find.byKey(Key('password')), 'password123');
    await tester.enterText(find.byKey(Key('confirm_password')), '321drowddap');

    await tester.tap(find.byKey(Key('register')));
    await tester.pumpAndSettle();

    expect(find.text('Passwords must be the same'), findsOneWidget);
  });

  testWidgets('User can successfully change the language', (
    WidgetTester tester,
  ) async {
    // Given
    tester.view.physicalSize = Size(1170, 2532);
    tester.view.devicePixelRatio = 1.5;

    // When
    await tester.pumpWidget(
      wrapWithProviders(
        RegisterScreen(bloc: registerBloc),
        additionalProviders: [
          Provider<LanguageCubit>.value(value: mockLanguageCubit),
          Provider<AccountBloc>.value(
            value: AccountBloc(authRepository, mockTokenStorageRepository),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.translate_rounded));

    await tester.pump();

    await tester.ensureVisible(find.text('Polski'));
    await tester.pumpAndSettle();

    expect(find.text('Polski'), findsOneWidget);
    await tester.tap(find.text('Polski'));
  });
}
