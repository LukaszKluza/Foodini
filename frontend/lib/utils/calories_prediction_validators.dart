import 'package:frontend/assets/calories_prediction_enums/activity_level.pb.dart';
import 'package:frontend/assets/calories_prediction_enums/sleep_quality.pb.dart';
import 'package:frontend/assets/calories_prediction_enums/stress_level.pb.dart';
import 'package:frontend/config/app_config.dart';

String? validateActivityLevel(ActivityLevel? value) {
  if (value == null) {
    return AppConfig.requiredActivityLevel;
  }
  return null;
}

String? validateStressLevel(StressLevel? value) {
  if (value == null) {
    return AppConfig.requiredStressLevel;
  }
  return null;
}

String? validateSleepQuality(SleepQuality? value) {
  if (value == null) {
    return AppConfig.requiredSleepQuality;
  }
  return null;
}

String? validateMusclePercentage(String? value) {
  final percentage = double.tryParse(value ?? '');
  if (percentage == null || percentage < 0 || percentage > 100) {
    return '${AppConfig.musclePercentageShouldBeBetween} [0, 100%]';
  }
  return null;
}

String? validateWaterPercentage(String? value) {
  final percentage = double.tryParse(value ?? '');
  if (percentage == null || percentage < 0 || percentage > 100) {
    return '${AppConfig.waterPercentageShouldBeBetween} [0, 100%]';
  }
  return null;
}

String? validateFatPercentage(String? value) {
  final percentage = double.tryParse(value ?? '');
  if (percentage == null || percentage < 0 || percentage > 100) {
    return '${AppConfig.fatPercentageShouldBeBetween} [0, 100%]';
  }
  return null;
}
