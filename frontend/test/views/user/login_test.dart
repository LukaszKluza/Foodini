import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blocs/user/login_bloc.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/events/user/login_events.dart';
import 'package:frontend/foodini.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/models/user/user_response.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/states/login_states.dart';
import 'package:frontend/views/screens/user/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mocks/mocks.mocks.dart';
import '../../wrapper/test_wrapper_builder.dart';

late MockDio mockDio;
late LoginBloc loginBloc;
late MockApiClient mockApiClient;
late UserRepository authRepository;
late MockLanguageCubit mockLanguageCubit;
late MockTokenStorageRepository mockTokenStorageRepository;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestWidget(
    Widget child, {
    List<GoRoute> additionalRoutes = const [],
    String initialLocation = '/login',
  }) {
    return TestWrapperBuilder(child)
        .withRouter()
        .addProvider(Provider<LanguageCubit>.value(value: mockLanguageCubit))
        .addRoutes(additionalRoutes)
        .setInitialLocation(initialLocation)
        .build();
  }

  setUp(() {
    mockDio = MockDio();
    mockApiClient = MockApiClient();
    mockLanguageCubit = MockLanguageCubit();
    authRepository = UserRepository(mockApiClient);
    mockTokenStorageRepository = MockTokenStorageRepository();
    loginBloc = LoginBloc(authRepository, mockTokenStorageRepository);
    SharedPreferences.setMockInitialValues({});

    when(mockDio.interceptors).thenReturn(Interceptors());
    when(mockLanguageCubit.state).thenReturn(Locale(Language.en.code));
  });

  testWidgets('Login screen elements are displayed', (
    WidgetTester tester,
  ) async {
    // Given, When
    await tester.pumpWidget(buildTestWidget(LoginScreen(bloc: loginBloc)));

    // Then
    expect(find.byIcon(Icons.translate_rounded), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(TextButton), findsNWidgets(3));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Login'), findsNWidgets(2));

    expect(loginBloc.state, isA<LoginInitial>());
  });

  testWidgets('User can log in successfully', (WidgetTester tester) async {
    // Given
    UserStorage().setUser(
      UserResponse(
        id: 1,
        name: 'Jan',
        language: Language.en,
        email: 'jan4@example.com',
      ),
    );

    when(mockApiClient.login(any)).thenAnswer(
      (_) async => Response<dynamic>(
        data: {
          'id': 1,
          'email': 'jan4@example.com',
          'access_token': 'access_token',
          'refresh_token': 'refresh_token',
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: Endpoints.login),
      ),
    );

    when(mockApiClient.getUser(1)).thenAnswer(
      (_) async => Response<dynamic>(
        data: {
          'id': 1,
          'email': 'jan4@example.com',
          'name': 'Jan',
          'language': 'pl',
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/user'),
      ),
    );

    // When
    await tester.pumpWidget(
      buildTestWidget(
        LoginScreen(bloc: loginBloc),
        additionalRoutes: [
          GoRoute(
            path: '/main-page',
            builder: (context, state) => Scaffold(body: Text('Foodini')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Then
    await tester.enterText(find.byKey(Key('e-mail')), 'jan4@example.com');
    await tester.enterText(find.byKey(Key('password')), 'Password1234');

    expect(loginBloc.state, isA<LoginInitial>());

    await tester.tap(find.byKey(Key('login')));
    await tester.pumpAndSettle();

    expect(loginBloc.state, isA<LoginSuccess>());

    await tester.pump(const Duration(milliseconds: Constants.redirectionDelay));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Foodini'), findsOneWidget);

    var loggedUser = UserStorage().getUser;
    expect(loggedUser, isNotNull);
    expect(loggedUser?.id, 1);
    expect(loggedUser?.email, 'jan4@example.com');
  });

  testWidgets('Login with missing email and password', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(buildTestWidget(LoginScreen(bloc: loginBloc)));

    // When
    await tester.tap(find.byKey(Key('login')));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('E-mail is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('Login with missing unverified account', (
    WidgetTester tester,
  ) async {
    // Given
    when(mockApiClient.login(any)).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: Endpoints.login),
        response: Response(
          requestOptions: RequestOptions(path: Endpoints.login),
          statusCode: 403,
          data: {'detail': 'EMAIL_NOT_VERIFIED'},
        ),
      ),
    );

    when(mockApiClient.resendVerificationMail(any)).thenAnswer(
      (_) async => Response<dynamic>(
        statusCode: 204,
        requestOptions: RequestOptions(
          path: '/users/confirm/resend-verification-new-account',
        ),
      ),
    );

    // When
    await tester.pumpWidget(buildTestWidget(LoginScreen(bloc: loginBloc)));
    await tester.pumpAndSettle();

    // Then
    await tester.enterText(find.byKey(Key('e-mail')), 'jan4@example.com');
    await tester.enterText(find.byKey(Key('password')), 'Password1234');

    expect(loginBloc.state, isA<LoginInitial>());

    await tester.tap(find.byKey(Key('login')));
    await tester.pumpAndSettle();

    expect(loginBloc.state, isA<AccountNotVerified>());

    expect(find.text('Your account has not been confirmed.'), findsOneWidget);
    expect(find.text('Send verification email again'), findsOneWidget);

    await tester.tap(find.byKey(Key('send_verification_email_again')));
    await tester.pumpAndSettle();

    expect(loginBloc.state, isA<ResendAccountVerificationSuccess>());
    expect(
      find.text('Email account verification send successfully'),
      findsOneWidget,
    );
  });

  testWidgets('Properly message after successful account verification', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(buildTestWidget(LoginScreen(bloc: loginBloc)));

    // When
    loginBloc.add(InitFromUrl('success'));
    await tester.pumpAndSettle();

    // Then
    expect(
      find.text('Account has been activated successfully'),
      findsOneWidget,
    );
  });

  testWidgets('Properly message when account has not been confirmed', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(buildTestWidget(LoginScreen(bloc: loginBloc)));

    // When
    loginBloc.add(InitFromUrl('error'));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Your account has not been confirmed.'), findsOneWidget);
    expect(find.text('Send verification email again'), findsOneWidget);
  });
}
