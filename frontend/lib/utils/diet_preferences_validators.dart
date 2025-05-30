import 'package:flutter/cupertino.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_intensity.pb.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_type.pb.dart';
import 'package:frontend/config/constants.dart';

import 'package:frontend/l10n/app_localizations.dart';

String? validateDietType(DietType? value, BuildContext context) {
  if (value == null) {
    return AppLocalizations.of(context)!.requiredDietType;
  }
  return null;
}

String? validateWeight(String? value, BuildContext context) {
  final weight = double.tryParse(value ?? '');
  if (weight == null ||
      weight < Constants.minWeight ||
      weight > Constants.maxWeight) {
    return '${AppLocalizations.of(context)!.dietGoalShouldBeBetween} [${Constants.minWeight}, ${Constants.maxWeight}]';
  }
  return null;
}

String? validateDietIntensity(DietIntensity? value, BuildContext context) {
  if (value == null) {
    return AppLocalizations.of(context)!.requiredDietIntensity;
  }
  return null;
}
