import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blocs/user_details/diet_preferences_bloc.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/views/screens/user_details/diet_preferences_screen.dart';

late DietPreferencesBloc dietPreferencesBloc;

void main() {
  setUp(() {
    dietPreferencesBloc = DietPreferencesBloc();
  });

  testWidgets('Diet preferences screen elements are displayed', (
    WidgetTester tester,
  ) async {
    // Given, When
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale('en'),
        home: DietPreferencesScreen(bloc: dietPreferencesBloc),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();

    // Then
    expect(find.byKey(Key('diet_type')), findsOneWidget);
    expect(find.byKey(Key('diet_intensity')), findsOneWidget);
    expect(find.text('Allergies'), findsOneWidget);
    expect(find.textContaining('Diet goal'), findsOneWidget);
    expect(find.text('Meals per day'), findsOneWidget);
    expect(find.text('Diet intensity'), findsOneWidget);
  });

  testWidgets('Diet type enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale('en'),
        home: DietPreferencesScreen(bloc: dietPreferencesBloc),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(Key('diet_type')));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Fat Loss'), findsOneWidget);
    expect(find.text('Muscle Gain'), findsOneWidget);
    expect(find.text('Weight Maintenance'), findsOneWidget);
    expect(find.text('Vegetarian'), findsOneWidget);
    expect(find.text('Vegan'), findsOneWidget);
    expect(find.text('Keto'), findsOneWidget);

    await tester.tap(find.text('Weight Maintenance'));
    await tester.pumpAndSettle();

    expect(find.text('Weight Maintenance'), findsOneWidget);
  });

  testWidgets('Allergies enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale('en'),
        home: DietPreferencesScreen(bloc: dietPreferencesBloc),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.text('Allergies'));
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
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale('en'),
        home: DietPreferencesScreen(bloc: dietPreferencesBloc),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
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
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale('en'),
        home: DietPreferencesScreen(bloc: dietPreferencesBloc),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
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
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale('en'),
        home: DietPreferencesScreen(bloc: dietPreferencesBloc),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Meals per day'), findsOneWidget);
    expect(find.textContaining('1'), findsOneWidget);
    expect(find.textContaining('2'), findsOneWidget);
    expect(find.textContaining('3'), findsOneWidget);
    expect(find.textContaining('4'), findsOneWidget);
    expect(find.textContaining('5'), findsOneWidget);
    expect(find.textContaining('6'), findsOneWidget);
  });

  testWidgets('Diet intensity enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale('en'),
        home: DietPreferencesScreen(bloc: dietPreferencesBloc),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(Key('diet_intensity')));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Slow'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Fast'), findsOneWidget);

    await tester.tap(find.text('Medium'));
    await tester.pumpAndSettle();

    expect(find.text('Medium'), findsOneWidget);
  });
}
