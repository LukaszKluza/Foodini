import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blocs/diet_generation/daily_summary_bloc.dart';
import 'package:frontend/blocs/user/account_bloc.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/blocs/user_details/macros_change_bloc.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/foodini.dart';
import 'package:frontend/models/user/change_language_request.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/models/user/user_response.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/states/account_states.dart';
import 'package:frontend/utils/cache_manager.dart';
import 'package:frontend/views/screens/user/account_screen.dart';
import 'package:frontend/views/screens/user/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid_value.dart';

import '../../mocks/mocks.mocks.dart';
import '../../wrapper/test_wrapper_builder.dart';

late MockDio mockDio;
late MockApiClient mockApiClient;
late MockCacheManager mockCacheManager;
late MockLanguageCubit mockLanguageCubit;
late MockUserDetailsRepository mockUserDetailsRepository;
late MockDietGenerationRepository mockDietGenerationRepository;
late MockTokenStorageService mockTokenStorageService;

late AccountBloc accountBloc;
late DietFormBloc dietFormBloc;
late MacrosChangeBloc macrosChangeBloc;
late DailySummaryBloc dailySummaryBloc;
late UserRepository authRepository;
late UuidValue uuidUserId;

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
        .addProvider(Provider<CacheManager>.value(value: mockCacheManager))
        .addProvider(BlocProvider<DietFormBloc>.value(value: dietFormBloc))
        .addProvider(BlocProvider<MacrosChangeBloc>.value(value: macrosChangeBloc))
        .addProvider(BlocProvider<DailySummaryBloc>.value(value: dailySummaryBloc))
        .addRoutes(additionalRoutes)
        .setInitialLocation(initialLocation)
        .build();
  }

  setUp(() {
    mockDio = MockDio();
    mockApiClient = MockApiClient();
    mockCacheManager = MockCacheManager();
    mockLanguageCubit = MockLanguageCubit();
    mockUserDetailsRepository = MockUserDetailsRepository();
    mockDietGenerationRepository = MockDietGenerationRepository();
    mockTokenStorageService = MockTokenStorageService();

    authRepository = UserRepository(mockApiClient);
    dietFormBloc = DietFormBloc(mockUserDetailsRepository);
    macrosChangeBloc = MacrosChangeBloc(mockUserDetailsRepository);
    dailySummaryBloc = DailySummaryBloc(mockDietGenerationRepository);
    accountBloc = AccountBloc(authRepository, mockTokenStorageService);

    uuidUserId = UuidValue.fromString('c4b678c3-bb44-5b37-90d9-5b0c9a4f1b87');

    when(mockDio.interceptors).thenReturn(Interceptors());
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    accountBloc.close();
    dietFormBloc.close();
    macrosChangeBloc.close();
  });

  testWidgets('Account screen shows all buttons', (WidgetTester tester) async {
    // Given, When
    UserStorage().setUser(
      UserResponse(
        id: uuidUserId,
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
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(accountBloc.state, isA<AccountInitial>());
  });

  testWidgets('Tap on Change password navigates to form', (tester) async {
    // Given, When
    UserStorage().setUser(
      UserResponse(
        id: uuidUserId,
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
    when(mockApiClient.logout(uuidUserId)).thenAnswer(
      (_) async => Response<dynamic>(
        statusCode: 204,
        requestOptions: RequestOptions(path: Endpoints.logout),
      ),
    );

    UserStorage().setUser(
      UserResponse(
        id: uuidUserId,
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

    final logoutButton = find.text('Logout');
    await tester.ensureVisible(logoutButton);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(accountBloc.state, isA<AccountLogoutSuccess>());

    await tester.pump(const Duration(milliseconds: Constants.redirectionDelay));
    await tester.pumpAndSettle();

    expect(find.text('Account logged out successfully'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('User can successfully delete account', (
    WidgetTester tester,
  ) async {
    // Given
    when(mockApiClient.delete(uuidUserId)).thenAnswer(
      (_) async => Response<dynamic>(
        statusCode: 204,
        requestOptions: RequestOptions(path: 'Delete'),
      ),
    );

    UserStorage().setUser(
      UserResponse(
        id: uuidUserId,
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

    final deleteButton = find.text('Delete account');
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));

    await tester.pump();

    expect(accountBloc.state, isA<AccountDeleteSuccess>());

    await tester.pump(const Duration(milliseconds: Constants.redirectionDelay));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Account deleted successfully'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('User close delete account pop-up', (WidgetTester tester) async {
    // Given
    UserStorage().setUser(
      UserResponse(
        id: uuidUserId,
        name: 'Jan',
        language: Language.en,
        email: 'jan4@example.com',
      ),
    );
    await tester.pumpWidget(buildTestWidget(AccountScreen(bloc: accountBloc)));

    // When
    await tester.pumpAndSettle();

    expect(accountBloc.state, isA<AccountInitial>());

    final deleteButton = find.text('Delete account');
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pump();

    // Then
    verifyZeroInteractions(mockDio);
    verifyZeroInteractions(mockApiClient);
    verifyZeroInteractions(mockTokenStorageService);
    expect(accountBloc.state, isA<AccountInitial>());
    expect(find.text('Delete account'), findsOneWidget);
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
        uuidUserId,
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: {
          'id': uuidUserId.uuid,
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
        id: uuidUserId,
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

    await tester.ensureVisible(find.text('Polski'));
    await tester.pumpAndSettle();

    expect(find.text('Polski'), findsOneWidget);
    await tester.tap(find.text('Polski'));

    await tester.pumpAndSettle();
    expect(accountBloc.state, isA<AccountChangeLanguageSuccess>());
  });
}
