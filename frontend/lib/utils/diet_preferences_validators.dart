import 'package:frontend/assets/diet_preferences_enums/diet_intensity.pb.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_type.pb.dart';
import 'package:frontend/config/app_config.dart';

String? validateDietType(DietType? value) {
  if (value == null) {
    return AppConfig.requiredDietType;
  }
  return null;
}

String? validateDietGoal(String? value) {
  final weight = double.tryParse(value ?? '');
  if (weight == null ||
      weight < AppConfig.minWeight ||
      weight > AppConfig.maxWeight) {
    return '${AppConfig.dietGoalShouldBeBetween} ${AppConfig.minWeight} and ${AppConfig.maxWeight}';
  }
  return null;
}

String? validateDietIntensity(DietIntensity? value) {
  if (value == null) {
    return AppConfig.requiredDietIntensity;
  }
  return null;
}
