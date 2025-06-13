import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blocs/user/provide_email_block.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/states/provide_email_states.dart';
import 'package:frontend/views/screens/user/provide_email_screen.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../mocks/mocks.mocks.dart';

late MockDio mockDio;
late MockApiClient mockApiClient;
late UserRepository authRepository;
late ProvideEmailBloc provideEmailBloc;
late MockTokenStorageRepository mockTokenStorageRepository;

Widget wrapWithProviders(Widget child, {List<GoRoute> routes = const []}) {
  final goRouter = GoRouter(
    initialLocation: '/',
    routes: [GoRoute(path: '/', builder: (context, state) => child), ...routes],
    errorBuilder: (context, state) => child,
  );

  return MultiProvider(
    providers: [Provider<UserRepository>.value(value: authRepository)],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: goRouter,
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockDio = MockDio();
    mockApiClient = MockApiClient();
    mockTokenStorageRepository = MockTokenStorageRepository();
    authRepository = UserRepository(mockApiClient);
    provideEmailBloc = ProvideEmailBloc(
      authRepository,
      tokenStorageRepository: mockTokenStorageRepository,
    );

    when(mockDio.interceptors).thenReturn(Interceptors());
    when(
      mockTokenStorageRepository.getAccessToken(),
    ).thenAnswer((_) async => null);
  });

  tearDown(() async {
    await provideEmailBloc.close();
  });

  testWidgets('Provide email elements and navbar are displayed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(ProvideEmailScreen(bloc: provideEmailBloc)),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(Key('e-mail')), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byType(BottomNavBar), findsOneWidget);
    expect(find.byIcon(Icons.translate_rounded), findsOneWidget);

    expect(provideEmailBloc.state, isA<ProvideEmailInitial>());
  });

  testWidgets('Submit without filling form shows validation errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(ProvideEmailScreen(bloc: provideEmailBloc)),
    );

    await tester.tap(find.byKey(Key('change_password')));
    await tester.pumpAndSettle();

    expect(provideEmailBloc.state, isA<ProvideEmailInitial>());
    expect(find.text('E-mail is required'), findsOneWidget);
  });

  testWidgets('ProvideEmail form submits with valid data and redirects', (
    WidgetTester tester,
  ) async {
    when(mockApiClient.provideEmail(any)).thenAnswer(
      (_) async => Response<dynamic>(
        data: {
          'id': 1,
          'email': 'john@example.com',
          'name': 'John',
          'language': 'pl',
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: Endpoints.changePassword),
      ),
    );

    final goRouter = GoRouter(
      initialLocation: '/provide-email',
      routes: [
        GoRoute(
          path: '/provide-email',
          builder:
              (context, state) => ProvideEmailScreen(bloc: provideEmailBloc),
        ),
        GoRoute(
          path: '/account',
          builder: (context, state) => const Scaffold(body: Text('Account')),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [Provider<UserRepository>.value(value: authRepository)],
        child: MaterialApp.router(
          routerConfig: goRouter,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(Key('e-mail')), 'john@example.com');
    await tester.tap(find.byKey(Key('change_password')));
    await tester.pumpAndSettle();

    expect(provideEmailBloc.state, isA<ProvideEmailSuccess>());
    expect(
      find.text('Check your email address to set new password'),
      findsOneWidget,
    );
  });
}
