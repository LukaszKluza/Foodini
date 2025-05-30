import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/assets/calories_prediction_enums/activity_level.pbenum.dart';
import 'package:frontend/blocs/calories_prediction_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/l10n/app_localizations.dart';
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
      MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CaloriesPredictionScreen(bloc: caloriesPredictionBloc),
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
      MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CaloriesPredictionScreen(bloc: caloriesPredictionBloc),
      ),
    );
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(Key('activity_level')));
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
      MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CaloriesPredictionScreen(bloc: caloriesPredictionBloc),
      ),
    );
    await tester.pumpAndSettle();
    // When
    final checkboxFinder = find.widgetWithText(CheckboxListTile, 'Advance body parameters');

    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    // Then
    expect(tester.widget<CheckboxListTile>(checkboxFinder).value, isTrue);
    expect(find.textContaining('Muscle percentage'), findsOneWidget);
    expect(find.textContaining('Water percentage'), findsOneWidget);
    expect(find.textContaining('Fat percentage', skipOffstage: false), findsOneWidget);
  });

  testWidgets('Muscle slider works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CaloriesPredictionScreen(bloc: caloriesPredictionBloc),
      ),
    );
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(CheckboxListTile, 'Advance body parameters');
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
      MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CaloriesPredictionScreen(bloc: caloriesPredictionBloc),
      ),
    );
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(CheckboxListTile, 'Advance body parameters');
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    final sliderFinder = find.byKey(Key('water_percentage'));
    await tester.drag(sliderFinder, const Offset(100, 0));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Water percentage: 65.0%'), findsOneWidget);
  });

  testWidgets('Fat slider works properly', (WidgetTester tester) async {
    // Given TODO Adjust it
    tester.view.physicalSize = Size(1170, 2532);
    tester.view.devicePixelRatio = 1.5;
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CaloriesPredictionScreen(bloc: caloriesPredictionBloc),
      ),
    );
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(CheckboxListTile, 'Advance body parameters');
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
      MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CaloriesPredictionScreen(bloc: caloriesPredictionBloc),
      ),
    );
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(CheckboxListTile, 'Advance body parameters');
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
      MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CaloriesPredictionScreen(bloc: caloriesPredictionBloc),
      ),
    );
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(CheckboxListTile, 'Advance body parameters');
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
      MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CaloriesPredictionScreen(bloc: caloriesPredictionBloc),
      ),
    );
    await tester.pumpAndSettle();

    // When
    final checkboxFinder = find.widgetWithText(CheckboxListTile, 'Advance body parameters');
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
