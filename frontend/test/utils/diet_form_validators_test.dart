import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_type.dart';
import 'package:frontend/utils/user_details/diet_preferences_validators.dart';

Future<BuildContext> pumpAppWithLocalization(WidgetTester tester) async {
  late BuildContext testContext;

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          testContext = context;
          return Container();
        },
      ),
    ),
  );

  return testContext;
}

void main() {
  group('Diet Validation Tests', () {
    testWidgets('validateDietType returns error when null', (tester) async {
      final context = await pumpAppWithLocalization(tester);

      expect(
        validateDietType(null, context),
        equals(AppLocalizations.of(context)!.requiredDietType),
      );
    });

    testWidgets('validateDietType returns null when provided', (tester) async {
      final context = await pumpAppWithLocalization(tester);

      expect(validateDietType(DietType.fatLoss, context), isNull);
    });

    testWidgets('validateDietGoal returns error when null or out of range', (
      tester,
    ) async {
      final context = await pumpAppWithLocalization(tester);

      expect(
        validateDietGoal(
          null,
          context,
          dietType: DietType.muscleGain,
          weight: 70,
        ),
        contains(AppLocalizations.of(context)!.dietGoalShouldBeBetween),
      );

      expect(
        validateDietGoal(
          (Constants.minWeight - 1).toString(),
          context,
          dietType: DietType.muscleGain,
          weight: 70,
        ),
        contains(AppLocalizations.of(context)!.dietGoalShouldBeBetween),
      );

      expect(
        validateDietGoal(
          (Constants.maxWeight + 1).toString(),
          context,
          dietType: DietType.muscleGain,
          weight: 70,
        ),
        contains(AppLocalizations.of(context)!.dietGoalShouldBeBetween),
      );
    });

    testWidgets(
      'validateDietGoal returns error when muscleGain goal < weight',
      (tester) async {
        final context = await pumpAppWithLocalization(tester);

        expect(
          validateDietGoal(
            '60',
            context,
            dietType: DietType.muscleGain,
            weight: 70,
          ),
          equals(AppLocalizations.of(context)!.muscleGainGoalCantBeLower),
        );
      },
    );

    testWidgets('validateDietGoal returns error when fatLoss goal > weight', (
      tester,
    ) async {
      final context = await pumpAppWithLocalization(tester);

      expect(
        validateDietGoal('80', context, dietType: DietType.fatLoss, weight: 70),
        equals(AppLocalizations.of(context)!.fatLossGoalCantBeHigher),
      );
    });

    testWidgets('validateDietGoal returns null for valid values', (
      tester,
    ) async {
      final context = await pumpAppWithLocalization(tester);

      expect(
        validateDietGoal(
          '75',
          context,
          dietType: DietType.muscleGain,
          weight: 70,
        ),
        isNull,
      );

      expect(
        validateDietGoal('65', context, dietType: DietType.fatLoss, weight: 70),
        isNull,
      );

      expect(
        validateDietGoal(
          '70',
          context,
          dietType: DietType.weightMaintenance,
          weight: 70,
        ),
        isNull,
      );
    });

    testWidgets('validateDietIntensity returns error when null', (
      tester,
    ) async {
      final context = await pumpAppWithLocalization(tester);

      expect(
        validateDietIntensity(null, context),
        equals(AppLocalizations.of(context)!.requiredDietIntensity),
      );
    });

    testWidgets('validateDietIntensity returns null when provided', (
      tester,
    ) async {
      final context = await pumpAppWithLocalization(tester);

      expect(validateDietIntensity(DietIntensity.medium, context), isNull);
    });
  });
}
