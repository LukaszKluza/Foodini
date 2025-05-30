import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/assets/diet_preferences_enums/allergy.pbenum.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_intensity.pbenum.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_type.pb.dart';
import 'package:frontend/blocs/diet_preferences_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/views/screens/diet_preferences_screen.dart';

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
    expect(
      find.text(AppConfig.dietTypeLabels[DietType.FAT_LOSS]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.dietTypeLabels[DietType.MUSCLE_GAIN]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.dietTypeLabels[DietType.WEIGHT_MAINTENANCE]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.dietTypeLabels[DietType.VEGETARIAN]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.dietTypeLabels[DietType.VEGAN]!),
      findsOneWidget,
    );
    expect(find.text(AppConfig.dietTypeLabels[DietType.KETO]!), findsOneWidget);

    await tester.tap(
      find.text(AppConfig.dietTypeLabels[DietType.WEIGHT_MAINTENANCE]!),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(AppConfig.dietTypeLabels[DietType.WEIGHT_MAINTENANCE]!),
      findsOneWidget,
    );
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
    expect(find.text(AppConfig.allergyLabels[Allergy.GLUTEN]!), findsOneWidget);
    expect(
      find.text(AppConfig.allergyLabels[Allergy.PEANUTS]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.allergyLabels[Allergy.LACTOSE]!),
      findsOneWidget,
    );
    expect(find.text(AppConfig.allergyLabels[Allergy.FISH]!), findsOneWidget);
    expect(find.text(AppConfig.allergyLabels[Allergy.SOY]!), findsOneWidget);
    expect(find.text(AppConfig.allergyLabels[Allergy.WHEAT]!), findsOneWidget);
    expect(find.text(AppConfig.allergyLabels[Allergy.CELERY]!), findsOneWidget);
    expect(
      find.text(AppConfig.allergyLabels[Allergy.SULPHITES]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.allergyLabels[Allergy.LUPIN]!, skipOffstage: false),
      findsOneWidget,
    );

    expect(
      find.text('Ok'.toUpperCase(), skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Cancel'.toUpperCase(), skipOffstage: false),
      findsOneWidget,
    );

    await tester.tap(find.text(AppConfig.allergyLabels[Allergy.LACTOSE]!));
    await tester.tap(find.text(AppConfig.allergyLabels[Allergy.SOY]!));
    await tester.tap(find.text(AppConfig.allergyLabels[Allergy.CELERY]!));

    await tester.tap(find.text('Ok'.toUpperCase()));
    await tester.pumpAndSettle();

    expect(
      find.text(AppConfig.allergyLabels[Allergy.LACTOSE]!),
      findsOneWidget,
    );
    expect(find.text(AppConfig.allergyLabels[Allergy.SOY]!), findsOneWidget);
    expect(find.text(AppConfig.allergyLabels[Allergy.CELERY]!), findsOneWidget);
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
    expect(
      find.text(AppConfig.dietIntensityLabels[DietIntensity.SLOW]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.dietIntensityLabels[DietIntensity.MEDIUM]!),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.dietIntensityLabels[DietIntensity.FAST]!),
      findsOneWidget,
    );

    await tester.tap(
      find.text(AppConfig.dietIntensityLabels[DietIntensity.MEDIUM]!),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(AppConfig.dietIntensityLabels[DietIntensity.MEDIUM]!),
      findsOneWidget,
    );
  });
}
