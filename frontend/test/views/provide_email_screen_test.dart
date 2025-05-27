import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:frontend/blocs/provide_email_block.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/states/provide_email_states.dart';
import 'package:frontend/views/screens/provide_email_screen.dart';

import '../mocks/mocks.mocks.dart';

late MockDio mockDio;
late MockApiClient mockApiClient;
late AuthRepository authRepository;
late ProvideEmailBloc provideEmailBloc;
late MockTokenStorageRepository mockTokenStorageRepository;

Widget wrapWithProviders(Widget child) {
  return MultiProvider(
    providers: [Provider<AuthRepository>.value(value: authRepository)],
    child: MaterialApp(home: child),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockDio = MockDio();
    mockApiClient = MockApiClient();
    mockTokenStorageRepository = MockTokenStorageRepository();
    authRepository = AuthRepository(mockApiClient);
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

  testWidgets('Provide email elements are displayed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(ProvideEmailScreen(bloc: provideEmailBloc)),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(Key(AppConfig.email)), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    expect(provideEmailBloc.state, isA<ProvideEmailInitial>());
  });

  testWidgets('Submit without filling form shows validation errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(ProvideEmailScreen(bloc: provideEmailBloc)),
    );

    await tester.tap(find.byKey(Key(AppConfig.changePassword)));
    await tester.pumpAndSettle();

    expect(provideEmailBloc.state, isA<ProvideEmailInitial>());
    expect(find.text(AppConfig.requiredEmail), findsOneWidget);
  });

  testWidgets('ProvideEmail form submits with valid data and redirects', (
    WidgetTester tester,
  ) async {
    when(mockApiClient.provideEmail(any)).thenAnswer(
      (_) async => Response<dynamic>(
        data: {'id': 1, 'email': 'john@example.com'},
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
          builder:
              (context, state) => const Scaffold(body: Text(AppConfig.account)),
        ),
      ],
    );

    await tester.pumpWidget(
      wrapWithProviders(MaterialApp.router(routerConfig: goRouter)),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(Key(AppConfig.email)),
      'john@example.com',
    );
    await tester.tap(find.byKey(Key(AppConfig.changePassword)));
    await tester.pumpAndSettle();

    expect(provideEmailBloc.state, isA<ProvideEmailSuccess>());
    expect(
      find.text(AppConfig.checkEmailAddressToSetNewPassword),
      findsOneWidget,
    );
  });
}
