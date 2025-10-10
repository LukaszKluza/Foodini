import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/foodini.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/models/user/user_response.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/repository/user_details/user_details_repository.dart';
import 'package:frontend/views/screens/main_page_screen.dart';
import 'package:frontend/views/screens/user_details/profile_details_screen.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:frontend/views/widgets/height_slider.dart';
import 'package:frontend/views/widgets/weight_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mocks/mocks.mocks.dart';
import '../../wrapper/test_wrapper_builder.dart';

late UserDetailsRepository userDetailsRepository;
late MockApiClient mockApiClient;
late MockLanguageCubit mockLanguageCubit;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late DietFormBloc dietFormBloc;

  Widget buildTestWidget(
    Widget child, {
    List<GoRoute> additionalRoutes = const [],
    String initialLocation = '/profile-details',
  }) {
    return TestWrapperBuilder(child)
        .withRouter()
        .addRoutes(additionalRoutes)
        .addProvider(Provider<LanguageCubit>.value(value: mockLanguageCubit))
        .addProvider(BlocProvider<DietFormBloc>.value(value: dietFormBloc))
        .setInitialLocation(initialLocation)
        .build();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});

    mockApiClient = MockApiClient();
    mockLanguageCubit = MockLanguageCubit();
    userDetailsRepository = UserDetailsRepository(mockApiClient);

    dietFormBloc = DietFormBloc(userDetailsRepository);
    UserStorage().setUser(
      UserResponse(
        id: 1,
        name: 'Jan',
        language: Language.en,
        email: 'jan4@example.com',
      ),
    );
    when(mockLanguageCubit.state).thenReturn(Locale(Language.en.code));
  });

  tearDown(() {
    dietFormBloc.close();
  });

  testWidgets('Profile details screen elements and navbar are displayed', (
    WidgetTester tester,
  ) async {
    // When
    await tester.pumpWidget(buildTestWidget(const ProfileDetailsScreen()));
    await tester.pumpAndSettle();

    // Then
    expect(find.byKey(Key('gender')), findsOneWidget);
    expect(find.byKey(Key('height')), findsOneWidget);
    expect(find.byKey(Key('weight')), findsOneWidget);
    expect(find.byKey(Key('date_of_birth')), findsOneWidget);
    expect(find.byType(BottomNavBar), findsOneWidget);
  });

  testWidgets(
    'Correctly render Profile details screen elements when user have no filled profile details',
    (tester) async {
      // Given
      when(mockApiClient.getDietPreferences(1)).thenAnswer((_) async {
        throw DioException(
          requestOptions: RequestOptions(path: Endpoints.dietPreferences),
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
        );
      });

      final routes = [
        GoRoute(
          path: '/main-page',
          builder: (context, state) => const MainPageScreen(),
        ),
        GoRoute(
          path: '/profile-details',
          builder: (context, state) => const ProfileDetailsScreen(),
        ),
      ];

      // When
      await tester.pumpWidget(
        buildTestWidget(
          const ProfileDetailsScreen(),
          additionalRoutes: routes,
          initialLocation: '/main-page',
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(ProfileDetailsScreen));
      final router = GoRouter.of(context);

      router.push('/profile-details', extra: {'from': 'main-page'});
      await tester.pumpAndSettle();

      // Then
      expect(find.byType(ProfileDetailsScreen), findsOneWidget);
      final weightSlider = tester.widget<WeightSlider>(
        find.byKey(Key('weight')),
      );
      expect(weightSlider.value, 65);

      final heightSlider = tester.widget<HeightSlider>(
        find.byKey(Key('height')),
      );
      expect(heightSlider.value, 175);
    },
  );

  testWidgets(
    'Correctly render Profile details screen elements when user have filled profile details',
    (WidgetTester tester) async {
      // Given
      when(mockApiClient.getDietPreferences(1)).thenAnswer((_) async {
        return Response(
          data: {
            'weight_kg': 48.0,
            'stress_level': 'medium',
            'date_of_birth': '2003-01-01',
            'sleep_quality': 'fair',
            'diet_type': 'muscle_gain',
            'muscle_percentage': null,
            'allergies': [],
            'water_percentage': null,
            'user_id': 1,
            'diet_goal_kg': 53.0,
            'fat_percentage': null,
            'id': 1,
            'meals_per_day': 4,
            'created_at': '2025-09-01T18:26:45.241412Z',
            'gender': 'female',
            'diet_intensity': 'normal',
            'updated_at': '2025-09-01T18:26:45.241412Z',
            'height_cm': 165.0,
            'activity_level': 'moderate',
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: Endpoints.dietPreferences),
        );
      });

      final routes = [
        GoRoute(
          path: '/main-page',
          builder: (context, state) => const MainPageScreen(),
        ),
        GoRoute(
          path: '/profile-details',
          builder: (context, state) => const ProfileDetailsScreen(),
        ),
      ];

      // When
      await tester.pumpWidget(
        buildTestWidget(
          const ProfileDetailsScreen(),
          additionalRoutes: routes,
          initialLocation: '/main-page',
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(ProfileDetailsScreen));
      final router = GoRouter.of(context);

      router.push('/profile-details', extra: {'from': 'main-page'});
      await tester.pumpAndSettle();

      // Then

      expect(find.byType(ProfileDetailsScreen), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(Key('gender')),
          matching: find.text('Female'),
        ),
        findsOneWidget,
      );
      expect(tester.widget<WeightSlider>(find.byKey(Key('weight'))).value, 48);
      expect(tester.widget<HeightSlider>(find.byKey(Key('height'))).value, 165);
      expect(
        tester
            .widget<TextFormField>(find.byKey(Key('date_of_birth')))
            .controller!
            .text,
        '01/01/2003',
      );
    },
  );

  testWidgets('Gender enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const ProfileDetailsScreen()));
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(Key('gender')));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Male'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);

    await tester.tap(find.text('Female'));
    await tester.pumpAndSettle();

    expect(find.text('Female'), findsOneWidget);
  });

  testWidgets('Height slider works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const ProfileDetailsScreen()));
    await tester.pumpAndSettle();

    // // When
    final sliderFinder = find.byKey(Key('height'));

    await tester.drag(sliderFinder, const Offset(15, 0));
    await tester.pumpAndSettle();

    // Then
    expect(find.textContaining('145'), findsOneWidget);
  });

  testWidgets('Weight slider works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const ProfileDetailsScreen()));
    await tester.pumpAndSettle();

    // // When
    final sliderFinder = find.byKey(Key('weight'));

    await tester.drag(sliderFinder, const Offset(15, 0));
    await tester.pumpAndSettle();

    // Then
    expect(find.textContaining('90'), findsOneWidget);
  });

  testWidgets('Height pop-up works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const ProfileDetailsScreen()));
    await tester.pumpAndSettle();

    // // When
    await tester.tap(find.textContaining('Height'));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Enter your height'), findsOneWidget);
    expect(find.textContaining('Height (cm)'), findsOneWidget);
    expect(find.text('Ok'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.enterText(find.byKey(Key('height-cm')), '177');

    await tester.tap(find.textContaining('Ok'));
    await tester.pumpAndSettle();

    expect(find.textContaining('177'), findsOneWidget);
  });

  testWidgets('Weight pop-up works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const ProfileDetailsScreen()));
    await tester.pumpAndSettle();

    // // When
    await tester.tap(find.textContaining('Weight'));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Enter your weight'), findsOneWidget);
    expect(find.textContaining('Weight (kg)'), findsOneWidget);
    expect(find.text('Ok'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.enterText(find.byKey(Key('weight_kg')), '77');

    await tester.tap(find.textContaining('Ok'));
    await tester.pumpAndSettle();

    expect(find.textContaining('77'), findsOneWidget);
  });

  testWidgets('Date picker appears on tap', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const ProfileDetailsScreen()));
    await tester.pumpAndSettle();

    // When
    final dateField = find.byKey(Key('date_of_birth'));
    expect(dateField, findsOneWidget);

    await tester.tap(dateField);
    await tester.pumpAndSettle();

    // Then
    expect(find.byType(CalendarDatePicker), findsOneWidget);
  });
}
