import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_type.dart';
import 'package:frontend/models/user_details/dietary_restriction.dart';
import 'package:frontend/states/diet_form_states.dart';
import 'package:frontend/views/screens/user_details/diet_preferences_screen.dart';
import 'package:go_router/go_router.dart';
import '../../mocks/mocks.mocks.dart';
import '../../wrapper/test_wrapper_builder.dart';

MockUserDetailsRepository mockUserDetailsRepository =
    MockUserDetailsRepository();

void main() {
  late DietFormBloc dietFormBloc;

  Widget buildTestWidget(
    Widget child, {
    String initialLocation = '/diet-preferences',
  }) {
    return TestWrapperBuilder(child)
        .withRouter()
        .addProvider(BlocProvider<DietFormBloc>.value(value: dietFormBloc))
        .setInitialLocation(initialLocation)
        .build();
  }

  setUp(() {
    dietFormBloc = DietFormBloc(mockUserDetailsRepository);
  });

  tearDown(() {
    dietFormBloc.close();
  });

  testWidgets('Diet preferences screen elements are displayed', (
    WidgetTester tester,
  ) async {
    // Given, When
    await tester.pumpWidget(buildTestWidget(const DietPreferencesScreen()));
    await tester.pumpAndSettle();

    // Then
    expect(find.byKey(const Key('diet_type')), findsOneWidget);
    expect(find.byKey(const Key('diet_intensity'), skipOffstage: false), findsOneWidget);
    expect(find.text('Dietary restrictions'), findsOneWidget);
    expect(find.textContaining('Diet goal'), findsOneWidget);
    expect(find.text('Meals per day'), findsOneWidget);
    expect(find.text('Diet intensity', skipOffstage: false), findsOneWidget);
  });

  testWidgets('Diet type enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const DietPreferencesScreen()));
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(const Key('diet_type')));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Fat Loss'), findsOneWidget);
    expect(find.text('Muscle Gain'), findsOneWidget);
    expect(find.text('Weight Maintenance'), findsOneWidget);

    await tester.tap(find.text('Weight Maintenance'));
    await tester.pumpAndSettle();

    expect(find.text('Weight Maintenance'), findsOneWidget);
  });

  testWidgets('Dietary restrictions enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const DietPreferencesScreen()));
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.text('Dietary restrictions'));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Gluten'), findsOneWidget);
    expect(find.text('Peanuts'), findsOneWidget);
    expect(find.text('Lactose'), findsOneWidget);
    expect(find.text('Fish'), findsOneWidget);
    expect(find.text('Soy'), findsOneWidget);
    expect(find.text('Wheat'), findsOneWidget);
    expect(find.text('Celery'), findsOneWidget);
    expect(find.text('Sulphites'), findsOneWidget);
    expect(find.text('Lupin', skipOffstage: false), findsOneWidget);
    expect(find.text('Vegetarian', skipOffstage: false), findsOneWidget);
    expect(find.text('Vegan', skipOffstage: false), findsOneWidget);
    expect(find.text('Keto', skipOffstage: false), findsOneWidget);

    expect(find.text('Ok'.toUpperCase(), skipOffstage: false), findsOneWidget);
    expect(
      find.text('Cancel'.toUpperCase(), skipOffstage: false),
      findsOneWidget,
    );

    await tester.tap(find.text('Lactose'));
    await tester.tap(find.text('Soy'));
    await tester.tap(find.text('Celery'));

    await tester.tap(find.text('Ok'.toUpperCase()));
    await tester.pumpAndSettle();

    expect(find.text('Lactose'), findsOneWidget);
    expect(find.text('Soy'), findsOneWidget);
    expect(find.text('Celery'), findsOneWidget);
  });

  testWidgets('Weight slider works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const DietPreferencesScreen()));
    await tester.pumpAndSettle();

    // When
    final sliderFinder = find.byType(Slider);

    await tester.drag(sliderFinder, const Offset(15, 0));
    await tester.pumpAndSettle();

    // Then
    expect(find.textContaining('90'), findsOneWidget);
  });

  testWidgets('Weight pop-up works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const DietPreferencesScreen()));
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.textContaining('Diet goal'));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Enter your diet goal'), findsOneWidget);
    expect(find.textContaining('Weight (kg)'), findsOneWidget);
    expect(find.text('Ok'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.enterText(find.byKey(Key('weight_kg')), '77');

    await tester.tap(find.textContaining('Ok'));
    await tester.pumpAndSettle();

    expect(find.textContaining('77'), findsOneWidget);
  });

  testWidgets('Meals per day section is displayed properties', (
    WidgetTester tester,
  ) async {
    // Given, When
    await tester.pumpWidget(buildTestWidget(const DietPreferencesScreen()));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Meals per day'), findsOneWidget);
    expect(find.textContaining('3'), findsOneWidget);
    expect(find.textContaining('4'), findsOneWidget);
    expect(find.textContaining('5'), findsAtLeastNWidgets(2));
    expect(find.textContaining('6'), findsAtLeastNWidgets(2));
  });

  testWidgets('Diet intensity enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    tester.view.devicePixelRatio = 1.5;

    await tester.pumpWidget(buildTestWidget(const DietPreferencesScreen()));
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(Key('diet_intensity')));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Slow'), findsOneWidget);
    expect(find.text('Medium', skipOffstage: false), findsWidgets);
    expect(find.text('Fast', skipOffstage: false), findsWidgets);

    await tester.tap(find.text('Medium', skipOffstage: false).last);
    await tester.pumpAndSettle();

    expect(find.text('Medium'), findsWidgets);
  });

  testWidgets('Weight slider is hidden when diet type is Weight Maintenance', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const DietPreferencesScreen()));
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(const Key('diet_type')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Weight Maintenance'));
    await tester.pumpAndSettle();

    // Then
    expect(find.byType(Slider), findsNothing);
  });

  testWidgets('Diet goal validation error messages are displayed', (
    WidgetTester tester,
  ) async {
    // Given
    dietFormBloc.emit(
      DietFormSubmit(
        dietType: DietType.muscleGain,
        dietGoal: 50,
        dietaryRestrictions: [DietaryRestriction.gluten],
        dietIntensity: DietIntensity.medium,
        mealsPerDay: 3,
        weight: 80,
      ),
    );

    final router = GoRouter(
      initialLocation: '/diet-preferences',
      routes: [
        GoRoute(
          path: '/diet-preferences',
          builder:
              (context, state) => BlocProvider<DietFormBloc>.value(
                value: dietFormBloc,
                child: const DietPreferencesScreen(),
              ),
        ),
      ],
    );

    // When
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );

    await tester.pumpAndSettle();

    // Then
    expect(find.textContaining('goal', findRichText: true), findsWidgets);
  });
}
