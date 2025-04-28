import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:frontend/blocs/register_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:frontend/states/register_states.dart';
import 'package:frontend/views/screens/register_screen.dart';

import '../mocks/mocks.mocks.dart';

late MockDio mockDio;
late RegisterBloc registerBloc;
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
    registerBloc = RegisterBloc(authRepository);
    mockTokenStorageRepository = MockTokenStorageRepository();
    when(mockDio.interceptors).thenReturn(Interceptors());
  });

  testWidgets('Register screen elements are displayed', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithProviders(RegisterScreen()));

    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Register form submits with valid data', (WidgetTester tester) async {
    when(mockApiClient.register(any)).thenAnswer(
          (_) async => Response<dynamic>(
        data: {'id': 1, 'email': 'john@example.com'},
        statusCode: 200,
        requestOptions: RequestOptions(path: AppConfig.registerUrl),
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
          builder: (context, state) => Scaffold(body: Text(AppConfig.login)),
        ),
      ],
    );

    await tester.pumpWidget(wrapWithProviders(MaterialApp.router(routerConfig: goRouter)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(Key(AppConfig.firstName)), 'John');
    await tester.enterText(find.byKey(Key(AppConfig.lastName)), 'Doe');
    await tester.tap(find.byKey(Key(AppConfig.age)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('18').last);
    await tester.pump();

    await tester.tap(find.byKey(Key(AppConfig.country)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Argentina'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(Key(AppConfig.email)), 'john@example.com');
    await tester.enterText(find.byKey(Key(AppConfig.password)), 'Password1234');
    await tester.enterText(find.byKey(Key(AppConfig.confirmPassword)), 'Password1234');

    expect(registerBloc.state, isA<RegisterInitial>());

    await tester.tap(find.byKey(Key(AppConfig.register)));
    await tester.pumpAndSettle();

    expect(registerBloc.state, isA<RegisterSuccess>());

    await tester.pump(const Duration(milliseconds: AppConfig.redirectionDelay));
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.login), findsOneWidget);
  });

  testWidgets('Registration without filled form', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithProviders(RegisterScreen()));

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsNWidgets(2));
    expect(find.text('E-mail is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    expect(find.text('Select your age'), findsOneWidget);
    expect(find.text('Select your country'), findsOneWidget);
    expect(find.text('Password confirmation is required'), findsOneWidget);
  });

  testWidgets('Registration with different passwords', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithProviders(RegisterScreen()));

    await tester.enterText(find.byKey(Key(AppConfig.password)), 'password123');
    await tester.enterText(
      find.byKey(Key(AppConfig.confirmPassword)),
      '321drowddap',
    );

    await tester.tap(find.byKey(Key(AppConfig.register)));
    await tester.pumpAndSettle();

    expect(find.text('Passwords must be the same'), findsOneWidget);
  });
}
