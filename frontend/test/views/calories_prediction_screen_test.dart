import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/assets/calories_prediction_enums/activity_level.pbenum.dart';
import 'package:frontend/assets/calories_prediction_enums/sleep_quality.pb.dart';
import 'package:frontend/assets/calories_prediction_enums/stress_level.pbserver.dart';
import 'package:frontend/blocs/diet_form_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/views/screens/calories_prediction_screen.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late DietFormBloc bloc;

  setUp(() {
    bloc = DietFormBloc();
  });

  tearDown(() {
    bloc.close();
  });

  Widget wrapWithRouter(Widget child) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder:
                (_, __) =>
                    BlocProvider<DietFormBloc>.value(value: bloc, child: child),
          ),
        ],
      ),
    );
  }

  testWidgets(
    'Basic Calories prediction screen elements and navbar are displayed',
    (WidgetTester tester) async {
      // Given, When
      await tester.pumpWidget(wrapWithRouter(const CaloriesPredictionScreen()));
      await tester.pumpAndSettle();

      // Then
      expect(find.byKey(Key(AppConfig.activityLevel)), findsOneWidget);
      expect(find.byKey(Key(AppConfig.stressLevel)), findsOneWidget);
      expect(find.byKey(Key(AppConfig.sleepQuality)), findsOneWidget);
      expect(find.text(AppConfig.advancedBodyParameters), findsOneWidget);
      expect(find.byType(BottomNavBar), findsOneWidget);
    },
  );

  testWidgets('Activity enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(wrapWithRouter(const CaloriesPredictionScreen()));
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(Key(AppConfig.activityLevel)));
    await tester.pumpAndSettle();

    // Then
    expect(
      find.text(AppConfig.activityLevelLabels[ActivityLevel.VERY_LOW]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.activityLevelLabels[ActivityLevel.LIGHT]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.activityLevelLabels[ActivityLevel.MODERATE]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.activityLevelLabels[ActivityLevel.ACTIVE]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.activityLevelLabels[ActivityLevel.VERY_ACTIVE]!),
      findsOneWidget,
    );

    await tester.tap(
      find.text(AppConfig.activityLevelLabels[ActivityLevel.MODERATE]!),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(AppConfig.activityLevelLabels[ActivityLevel.MODERATE]!),
      findsOneWidget,
    );
  });

  testWidgets('Stress level enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(wrapWithRouter(const CaloriesPredictionScreen()));
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(Key(AppConfig.stressLevel)));
    await tester.pumpAndSettle();

    // Then
    expect(
      find.text(AppConfig.stressLevelLabels[StressLevel.LOW]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.stressLevelLabels[StressLevel.MEDIUM]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.stressLevelLabels[StressLevel.HIGH]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.stressLevelLabels[StressLevel.EXTREME]!),
      findsOneWidget,
    );

    await tester.tap(
      find.text(AppConfig.stressLevelLabels[StressLevel.MEDIUM]!),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(AppConfig.stressLevelLabels[StressLevel.MEDIUM]!),
      findsOneWidget,
    );
  });

  testWidgets('Sleep quality enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(wrapWithRouter(const CaloriesPredictionScreen()));
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(Key(AppConfig.sleepQuality)));
    await tester.pumpAndSettle();

    // Then
    expect(
      find.text(AppConfig.sleepQualityLabels[SleepQuality.POOR]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.sleepQualityLabels[SleepQuality.FAIR]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.sleepQualityLabels[SleepQuality.GOOD]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.sleepQualityLabels[SleepQuality.EXCELLENT]!),
      findsOneWidget,
    );

    await tester.tap(
      find.text(AppConfig.sleepQualityLabels[SleepQuality.GOOD]!),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(AppConfig.sleepQualityLabels[SleepQuality.GOOD]!),
      findsOneWidget,
    );
  });

  testWidgets('Advanced options are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(wrapWithRouter(const CaloriesPredictionScreen()));
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(
      CheckboxListTile,
      AppConfig.advancedBodyParameters,
    );

    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    // Then
    expect(tester.widget<CheckboxListTile>(checkboxFinder).value, isTrue);
    expect(find.textContaining(AppConfig.musclePercentage), findsOneWidget);
    expect(find.textContaining(AppConfig.waterPercentage), findsOneWidget);
    expect(
      find.textContaining(AppConfig.fatPercentage, skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('Muscle slider works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(wrapWithRouter(const CaloriesPredictionScreen()));
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(
      CheckboxListTile,
      AppConfig.advancedBodyParameters,
    );
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    final sliderFinder = find.byKey(Key(AppConfig.musclePercentage));
    await tester.drag(sliderFinder, const Offset(-100, 0));
    await tester.pumpAndSettle();

    // Then
    expect(find.text("Muscle percentage: 35.0%"), findsOneWidget);
  });

  testWidgets('Water slider works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(wrapWithRouter(const CaloriesPredictionScreen()));
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(
      CheckboxListTile,
      AppConfig.advancedBodyParameters,
    );
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    final sliderFinder = find.byKey(Key(AppConfig.waterPercentage));

    final slider = tester.getCenter(sliderFinder);
    await tester.dragFrom(slider, const Offset(100, 0));
    await tester.pumpAndSettle();

    // Then
    expect(find.textContaining("Water percentage:"), findsOneWidget);

    final textFinder = find.textContaining("Water percentage:");
    expect(textFinder, findsOneWidget);
    final textWidget = tester.widget<Text>(textFinder);
    expect(textWidget.data, contains("60.0%"));
  });

  testWidgets('Fat slider works properly', (WidgetTester tester) async {
    // Given TODO Adjust it
    tester.view.physicalSize = Size(1170, 2532);
    tester.view.devicePixelRatio = 1.5;
    await tester.pumpAndSettle();

    await tester.pumpWidget(wrapWithRouter(const CaloriesPredictionScreen()));
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(
      CheckboxListTile,
      AppConfig.advancedBodyParameters,
    );
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    final sliderFinder = find.byKey(Key(AppConfig.fatPercentage));
    await tester.drag(sliderFinder, const Offset(-250, 0));
    await tester.pumpAndSettle();

    // Then
    expect(find.text("Fat percentage: 12.0%"), findsOneWidget);
  });

  testWidgets('Muscle pop-up works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(wrapWithRouter(const CaloriesPredictionScreen()));
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(
      CheckboxListTile,
      AppConfig.advancedBodyParameters,
    );
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining(AppConfig.musclePercentage));
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.enterMusclePercentage), findsOneWidget);
    expect(find.text(AppConfig.musclePercentage), findsOneWidget);
    expect(find.text(AppConfig.ok), findsOneWidget);
    expect(find.text(AppConfig.cancel), findsOneWidget);

    await tester.enterText(find.byKey(Key(AppConfig.musclePercentage)), '38');

    await tester.tap(find.textContaining(AppConfig.ok));
    await tester.pumpAndSettle();

    expect(find.textContaining('38'), findsOneWidget);
  });

  testWidgets('Water pop-up works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(wrapWithRouter(const CaloriesPredictionScreen()));
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(
      CheckboxListTile,
      AppConfig.advancedBodyParameters,
    );
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining(AppConfig.waterPercentage));
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.enterWaterPercentage), findsOneWidget);
    expect(find.text(AppConfig.waterPercentage), findsOneWidget);
    expect(find.text(AppConfig.ok), findsOneWidget);
    expect(find.text(AppConfig.cancel), findsOneWidget);

    await tester.enterText(find.byKey(Key(AppConfig.waterPercentage)), '66');

    await tester.tap(find.textContaining(AppConfig.ok));
    await tester.pumpAndSettle();

    expect(find.textContaining('66'), findsOneWidget);
  });

  testWidgets('Fat pop-up works properly', (WidgetTester tester) async {
    // Given
    tester.view.physicalSize = Size(1170, 2532);
    tester.view.devicePixelRatio = 1.5;
    await tester.pumpAndSettle();

    await tester.pumpWidget(wrapWithRouter(const CaloriesPredictionScreen()));
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(
      CheckboxListTile,
      AppConfig.advancedBodyParameters,
    );
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining(AppConfig.fatPercentage));
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.enterFatPercentage), findsOneWidget);
    expect(find.text(AppConfig.fatPercentage), findsOneWidget);
    expect(find.text(AppConfig.ok), findsOneWidget);
    expect(find.text(AppConfig.cancel), findsOneWidget);

    await tester.enterText(find.byKey(Key(AppConfig.fatPercentage)), '13.5');

    await tester.tap(find.textContaining(AppConfig.ok));
    await tester.pumpAndSettle();

    expect(find.textContaining('13.5'), findsOneWidget);
  });
}
