import 'package:flutter/cupertino.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/activity_level.dart';
import 'package:frontend/models/user_details/sleep_quality.dart';
import 'package:frontend/models/user_details/stress_level.dart';

String? validateActivityLevel(ActivityLevel? value, BuildContext context) {
  if (value == null) {
    return AppLocalizations.of(context)!.requiredActivityLevel;
  }
  return null;
}

String? validateStressLevel(StressLevel? value, BuildContext context) {
  if (value == null) {
    return AppLocalizations.of(context)!.requiredStressLevel;
  }
  return null;
}

String? validateSleepQuality(SleepQuality? value, BuildContext context) {
  if (value == null) {
    return AppLocalizations.of(context)!.requiredSleepQuality;
  }
  return null;
}

String? validateMusclePercentage(String? value, BuildContext context) {
  final percentage = double.tryParse(value ?? '');
  if (percentage == null || percentage < 0 || percentage > 100) {
    return '${AppLocalizations.of(context)!.musclePercentageShouldBeBetween} [0, 100%]';
  }
  return null;
}

String? validateWaterPercentage(String? value, BuildContext context) {
  final percentage = double.tryParse(value ?? '');
  if (percentage == null || percentage < 0 || percentage > 100) {
    return '${AppLocalizations.of(context)!.waterPercentageShouldBeBetween} [0, 100%]';
  }
  return null;
}

String? validateFatPercentage(String? value, BuildContext context) {
  final percentage = double.tryParse(value ?? '');
  if (percentage == null || percentage < 0 || percentage > 100) {
    return '${AppLocalizations.of(context)!.fatPercentageShouldBeBetween} [0, 100%]';
  }
  return null;
}

String? validateAdvancedParameters(double value, BuildContext context) {
  if (value > 100) {
    return '${AppLocalizations.of(context)!.advancedParametersValidation} 100%';
  }
  return null;
}
