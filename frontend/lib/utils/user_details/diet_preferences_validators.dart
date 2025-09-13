import 'package:flutter/cupertino.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_type.dart';

String? validateDietType(DietType? value, BuildContext context) {
  if (value == null) {
    return AppLocalizations.of(context)!.requiredDietType;
  }
  return null;
}

String? validateDietGoal(String? value, BuildContext context, {DietType? dietType, double? weight}) {
  final goal = double.tryParse(value ?? '');
  if (goal == null ||
      goal < Constants.minWeight ||
      goal > Constants.maxWeight) {
    return '${AppLocalizations.of(context)!.dietGoalShouldBeBetween} [${Constants.minWeight}, ${Constants.maxWeight}]';
  } else if (dietType == DietType.muscleGain && goal < weight!) {
    return AppLocalizations.of(context)!.muscleGainGoalCantBeLower;
  } else if (dietType == DietType.fatLoss && goal > weight!) {
    return AppLocalizations.of(context)!.fatLossGoalCantBeHigher;
  }
  return null;
}

String? validateDietIntensity(DietIntensity? value, BuildContext context) {
  if (value == null) {
    return AppLocalizations.of(context)!.requiredDietIntensity;
  }
  return null;
}
