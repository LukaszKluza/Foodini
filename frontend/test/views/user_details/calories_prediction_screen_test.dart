import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/views/screens/user_details/calories_prediction_screen.dart';

import '../../mocks/mocks.mocks.dart';
import '../../wrapper/test_wrapper_builder.dart';

MockUserDetailsRepository mockUserDetailsRepository =
    MockUserDetailsRepository();

void main() {
  final dietFormBloc = DietFormBloc(mockUserDetailsRepository);

  Widget buildTestWidget(Widget child, {DietFormBloc? customBloc}) {
    return TestWrapperBuilder(child)
        .withRouter()
        .addProvider(
          BlocProvider<DietFormBloc>.value(value: customBloc ?? dietFormBloc),
        )
        .build();
  }

  testWidgets('Basic Calories prediction screen elements are displayed', (
    WidgetTester tester,
  ) async {
    // Given, When
    await tester.pumpWidget(
      buildTestWidget(
        const CaloriesPredictionScreen(),
        customBloc: dietFormBloc,
      ),
    );
    await tester.pumpAndSettle();

    // Then
    expect(find.byKey(Key('activity_level')), findsOneWidget);
    expect(find.byKey(Key('stress_level')), findsOneWidget);
    expect(find.byKey(Key('sleep_quality')), findsOneWidget);
    expect(find.text('Advance body parameters'), findsOneWidget);
  });

  testWidgets('Activity enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(
      buildTestWidget(
        const CaloriesPredictionScreen(),
        customBloc: dietFormBloc,
      ),
    );
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(Key('activity_level')));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Very Low (1–2 days a week or less)'), findsOneWidget);
    expect(find.text('Low (2–3 days a week)'), findsOneWidget);
    expect(find.text('Moderate (3–4 days a week)'), findsOneWidget);
    expect(find.text('Active (5–6 days a week)'), findsOneWidget);
    expect(find.text('Very Active (daily activity)'), findsOneWidget);

    await tester.tap(find.text('Moderate (3–4 days a week)'));
    await tester.pumpAndSettle();

    expect(find.text('Moderate (3–4 days a week)'), findsOneWidget);
  });

  testWidgets('Stress level enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(
      buildTestWidget(
        const CaloriesPredictionScreen(),
        customBloc: dietFormBloc,
      ),
    );
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(Key('stress_level')));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Low'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('Extreme'), findsOneWidget);

    await tester.tap(find.text('Medium'));
    await tester.pumpAndSettle();

    expect(find.text('Medium'), findsOneWidget);
  });

  testWidgets('Sleep quality enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(
      buildTestWidget(
        const CaloriesPredictionScreen(),
        customBloc: dietFormBloc,
      ),
    );
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(Key('sleep_quality')));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Poor'), findsOneWidget);
    expect(find.text('Fair'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
    expect(find.text('Excellent'), findsOneWidget);

    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();

    expect(find.text('Good'), findsOneWidget);
  });

  testWidgets('Advanced options are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(
      buildTestWidget(
        const CaloriesPredictionScreen(),
        customBloc: dietFormBloc,
      ),
    );
    await tester.pumpAndSettle();
    // When
    final checkboxFinder = find.widgetWithText(
      CheckboxListTile,
      'Advance body parameters',
    );

    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    // Then
    expect(tester.widget<CheckboxListTile>(checkboxFinder).value, isTrue);
    expect(find.textContaining('Muscle percentage'), findsOneWidget);
    expect(find.textContaining('Water percentage'), findsOneWidget);
    expect(
      find.textContaining('Fat percentage', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('Muscle slider works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(
      buildTestWidget(
        const CaloriesPredictionScreen(),
        customBloc: dietFormBloc,
      ),
    );
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(
      CheckboxListTile,
      'Advance body parameters',
    );
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    final sliderFinder = find.byKey(Key('muscle_percentage'));
    await tester.drag(sliderFinder, const Offset(-100, 0));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Muscle percentage: 35.0%'), findsOneWidget);
  });

  testWidgets('Water slider works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(
      buildTestWidget(
        const CaloriesPredictionScreen(),
        customBloc: dietFormBloc,
      ),
    );
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(
      CheckboxListTile,
      'Advance body parameters',
    );
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    final sliderFinder = find.byKey(Key('water_percentage'));
    await tester.drag(sliderFinder, const Offset(50, 0));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Water percentage: 57.0%'), findsOneWidget);
  });

  testWidgets('Fat slider works properly', (WidgetTester tester) async {
    // Given TODO Adjust it
    tester.view.physicalSize = Size(1170, 2532);
    tester.view.devicePixelRatio = 1.5;
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      buildTestWidget(
        const CaloriesPredictionScreen(),
        customBloc: dietFormBloc,
      ),
    );
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(
      CheckboxListTile,
      'Advance body parameters',
    );
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    final sliderFinder = find.byKey(Key('fat_percentage'));
    await tester.drag(sliderFinder, const Offset(-250, 0));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Fat percentage: 12.0%'), findsOneWidget);
  });

  testWidgets('Muscle pop-up works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(
      buildTestWidget(
        const CaloriesPredictionScreen(),
        customBloc: dietFormBloc,
      ),
    );
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(
      CheckboxListTile,
      'Advance body parameters',
    );
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Muscle percentage'));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Enter your muscle %'), findsOneWidget);
    expect(find.text('Muscle percentage'), findsOneWidget);
    expect(find.text('Ok'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.enterText(find.byKey(Key('muscle_percentage')), '38');

    await tester.tap(find.textContaining('Ok'));
    await tester.pumpAndSettle();

    expect(find.textContaining('38'), findsOneWidget);
  });

  testWidgets('Water pop-up works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(
      buildTestWidget(
        const CaloriesPredictionScreen(),
        customBloc: dietFormBloc,
      ),
    );
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(
      CheckboxListTile,
      'Advance body parameters',
    );
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Water percentage'));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Enter your water percentage'), findsOneWidget);
    expect(find.text('Water percentage'), findsOneWidget);
    expect(find.text('Ok'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.enterText(find.byKey(Key('water_percentage')), '66');

    await tester.tap(find.textContaining('Ok'));
    await tester.pumpAndSettle();

    expect(find.textContaining('66'), findsOneWidget);
  });

  testWidgets('Fat pop-up works properly', (WidgetTester tester) async {
    // Given
    tester.view.physicalSize = Size(1170, 2532);
    tester.view.devicePixelRatio = 1.5;

    await tester.pumpWidget(
      buildTestWidget(
        const CaloriesPredictionScreen(),
        customBloc: dietFormBloc,
      ),
    );
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(
      CheckboxListTile,
      'Advance body parameters',
    );
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Fat percentage'));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Enter your fat percentage'), findsOneWidget);
    expect(find.text('Fat percentage'), findsOneWidget);
    expect(find.text('Ok'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.enterText(find.byKey(Key('fat_percentage')), '13.5');

    await tester.tap(find.textContaining('Ok'));
    await tester.pumpAndSettle();

    expect(find.textContaining('13.5'), findsOneWidget);
  });
}
