import 'package:flutter/cupertino.dart';
import 'package:frontend/assets/calories_prediction_enums/activity_level.pb.dart';
import 'package:frontend/assets/calories_prediction_enums/sleep_quality.pb.dart';
import 'package:frontend/assets/calories_prediction_enums/stress_level.pb.dart';
import 'package:frontend/l10n/app_localizations.dart';

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
