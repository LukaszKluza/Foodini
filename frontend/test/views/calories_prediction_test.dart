import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/assets/calories_prediction_enums/activity_level.pbenum.dart';
import 'package:frontend/blocs/calories_prediction_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/views/screens/calories_prediction_screen.dart';

late CaloriesPredictionBloc caloriesPredictionBloc;

void main() {
  setUp(() {
    caloriesPredictionBloc = CaloriesPredictionBloc();
  });

  testWidgets('Basic Calories prediction screen elements are displayed', (
    WidgetTester tester,
  ) async {
    // Given, When
    await tester.pumpWidget(
      MaterialApp(home: CaloriesPredictionScreen(bloc: caloriesPredictionBloc)),
    );
    await tester.pumpAndSettle();

    // Then
    expect(find.byKey(Key(AppConfig.activityLevel)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.stressLevel)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.sleepQuality)), findsOneWidget);
    expect(find.text(AppConfig.advancedBodyParameters), findsOneWidget);
  });

  testWidgets('Activity enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(
      MaterialApp(home: CaloriesPredictionScreen(bloc: caloriesPredictionBloc)),
    );
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

  testWidgets('Advanced options are displayed after tap', (
      WidgetTester tester,
      ) async {
    // Given
    await tester.pumpWidget(
      MaterialApp(home: CaloriesPredictionScreen(bloc: caloriesPredictionBloc)),
    );
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(CheckboxListTile, AppConfig.advancedBodyParameters);

    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    // Then
    expect(tester.widget<CheckboxListTile>(checkboxFinder).value, isTrue);
    expect(find.textContaining(AppConfig.musclePercentage), findsOneWidget);
    expect(find.textContaining(AppConfig.waterPercentage), findsOneWidget);
    expect(find.textContaining(AppConfig.fatPercentage, skipOffstage: false), findsOneWidget);
  });
}
