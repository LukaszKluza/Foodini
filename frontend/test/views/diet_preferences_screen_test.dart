import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/assets/diet_preferences_enums/allergy.pbenum.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_intensity.pbenum.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_type.pb.dart';
import 'package:frontend/blocs/diet_form_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/views/screens/diet_preferences_screen.dart';

void main() {

  final bloc = DietFormBloc();

  testWidgets('Diet preferences screen elements are displayed', (
    WidgetTester tester,
  ) async {
    // Given, When
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DietFormBloc>.value(
          value: bloc,
          child: const DietPreferencesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Then
    expect(find.byKey(Key(AppConfig.dietType)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.dietIntensity)), findsOneWidget);
    expect(find.text(AppConfig.allergies), findsOneWidget);
    expect(find.textContaining(AppConfig.dietGoal), findsOneWidget);
    expect(find.text(AppConfig.mealsPerDay), findsOneWidget);
    expect(find.text(AppConfig.dietIntensity), findsOneWidget);
  });

  testWidgets('Diet type enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DietFormBloc>.value(
          value: bloc,
          child: const DietPreferencesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(Key(AppConfig.dietType)));
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
        home: BlocProvider<DietFormBloc>.value(
          value: bloc,
          child: const DietPreferencesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.text(AppConfig.allergies));
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
      find.text(AppConfig.ok.toUpperCase(), skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text(AppConfig.cancel.toUpperCase(), skipOffstage: false),
      findsOneWidget,
    );

    await tester.tap(find.text(AppConfig.allergyLabels[Allergy.LACTOSE]!));
    await tester.tap(find.text(AppConfig.allergyLabels[Allergy.SOY]!));
    await tester.tap(find.text(AppConfig.allergyLabels[Allergy.CELERY]!));

    await tester.tap(find.text(AppConfig.ok.toUpperCase()));
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
        home: BlocProvider<DietFormBloc>.value(
          value: bloc,
          child: const DietPreferencesScreen(),
        ),
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
        home: BlocProvider<DietFormBloc>.value(
          value: bloc,
          child: const DietPreferencesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.textContaining(AppConfig.dietGoal));
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.enterYourDietGoal), findsOneWidget);
    expect(find.textContaining(AppConfig.weightKg), findsOneWidget);
    expect(find.text(AppConfig.ok), findsOneWidget);
    expect(find.text(AppConfig.cancel), findsOneWidget);

    await tester.enterText(find.byKey(Key(AppConfig.weightKg)), '77');

    await tester.tap(find.textContaining(AppConfig.ok));
    await tester.pumpAndSettle();

    expect(find.textContaining('77'), findsOneWidget);
  });

  testWidgets('Meals per day section is displayed properties', (
    WidgetTester tester,
  ) async {
    // Given, When
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DietFormBloc>.value(
          value: bloc,
          child: const DietPreferencesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.mealsPerDay), findsOneWidget);
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
        home: BlocProvider<DietFormBloc>.value(
          value: bloc,
          child: const DietPreferencesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(Key(AppConfig.dietIntensity)));
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
