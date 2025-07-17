import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/foodini.dart';
import 'package:frontend/models/user/change_language_request.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/models/user/user_response.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/views/screens/user/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/blocs/user/account_bloc.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/states/account_states.dart';
import 'package:frontend/views/screens/user/account_screen.dart';

import '../../mocks/mocks.mocks.dart';
import '../../wrapper/test_wrapper_builder.dart';

late MockDio mockDio;
late AccountBloc accountBloc;
late DietFormBloc dietFormBloc;
late MockApiClient mockApiClient;
late UserRepository authRepository;
late UserStorage userStorage;
late MockTokenStorageRepository mockTokenStorageRepository;
late MockUserDetailsRepository mockUserDetailsRepository;
late MockLanguageCubit mockLanguageCubit;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestWidget(
    Widget child, {
    List<GoRoute> additionalRoutes = const [],
    String initialLocation = '/account',
  }) {
    return TestWrapperBuilder(child)
        .withRouter()
        .addProvider(Provider<LanguageCubit>.value(value: mockLanguageCubit))
        .addProvider(BlocProvider<DietFormBloc>.value(value: dietFormBloc))
        .addRoutes(additionalRoutes)
        .setInitialLocation(initialLocation)
        .build();
  }

  setUp(() {
    mockDio = MockDio();
    mockApiClient = MockApiClient();
    userStorage = UserStorage();
    authRepository = UserRepository(mockApiClient);
    mockLanguageCubit = MockLanguageCubit();
    mockTokenStorageRepository = MockTokenStorageRepository();
    mockUserDetailsRepository = MockUserDetailsRepository();
    accountBloc = AccountBloc(authRepository, mockTokenStorageRepository);
    dietFormBloc = DietFormBloc(mockUserDetailsRepository);
    when(mockDio.interceptors).thenReturn(Interceptors());
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Account screen shows all buttons', (WidgetTester tester) async {
    // Given, When
    UserStorage().setUser(
      UserResponse(
        id: 1,
        name: 'Jan',
        language: Language.en,
        email: 'jan4@example.com',
      ),
    );
    await tester.pumpWidget(buildTestWidget(AccountScreen(bloc: accountBloc)));
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
    // Given, When
    UserStorage().setUser(
      UserResponse(
        id: 1,
        name: 'Jan',
        language: Language.en,
        email: 'jan4@example.com',
      ),
    );
    await tester.pumpWidget(
      buildTestWidget(
        AccountScreen(bloc: accountBloc),
        additionalRoutes: [
          GoRoute(
            path: '/provide-email',
            builder:
                (context, state) => const Scaffold(key: Key('change_password')),
          ),
        ],
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
      UserResponse(
        id: 1,
        name: 'Jan',
        language: Language.en,
        email: 'jan4@example.com',
      ),
    );

    // When
    await tester.pumpWidget(
      buildTestWidget(
        AccountScreen(bloc: accountBloc),
        additionalRoutes: [
          GoRoute(path: '/', builder: (context, state) => HomeScreen()),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(accountBloc.state, isA<AccountInitial>());

    await tester.tap(find.text('Logout'));
    await tester.pump();

    expect(accountBloc.state, isA<AccountLogoutSuccess>());

    await tester.pump(const Duration(milliseconds: Constants.redirectionDelay));
    await tester.pumpAndSettle();

    expect(find.text('Account logged out successfully'), findsOneWidget);
    expect(find.text('Foodini Home Page'), findsOneWidget);
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
      UserResponse(
        id: 1,
        name: 'Jan',
        language: Language.pl,
        email: 'jan4@example.com',
      ),
    );

    // When
    await tester.pumpWidget(
      buildTestWidget(
        AccountScreen(bloc: accountBloc),
        additionalRoutes: [
          GoRoute(path: '/', builder: (context, state) => HomeScreen()),
        ],
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
    expect(find.text('Foodini Home Page'), findsOneWidget);
  });

  testWidgets('User close delete account pop-up', (WidgetTester tester) async {
    // Given
    UserStorage().setUser(
      UserResponse(
        id: 1,
        name: 'Jan',
        language: Language.en,
        email: 'jan4@example.com',
      ),
    );
    await tester.pumpWidget(buildTestWidget(AccountScreen(bloc: accountBloc)));

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

  testWidgets('User can successfully change the language', (
    WidgetTester tester,
  ) async {
    // Given
    when(
      mockApiClient.changeLanguage(
        argThat(
          isA<ChangeLanguageRequest>().having(
            (r) => r.language,
            'language',
            Language.pl,
          ),
        ),
        1,
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: {
          'id': 1,
          'email': 'jan4@example.com',
          'name': 'Jan',
          'language': 'pl',
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: Endpoints.changeLanguage),
      ),
    );

    UserStorage().setUser(
      UserResponse(
        id: 1,
        name: 'Jan',
        language: Language.en,
        email: 'jan4@example.com',
      ),
    );

    // When
    await tester.pumpWidget(buildTestWidget(AccountScreen(bloc: accountBloc)));

    await tester.pumpAndSettle();

    await tester.tap(find.text('Change language'));
    await tester.pump();

    await tester.ensureVisible(find.text("Polski"));
    await tester.pumpAndSettle();

    expect(find.text('Polski'), findsOneWidget);
    await tester.tap(find.text("Polski"));

    await tester.pumpAndSettle();
    expect(accountBloc.state, isA<AccountChangeLanguageSuccess>());
  });
}
