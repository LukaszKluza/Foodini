import 'package:frontend/assets/diet_preferences_enums/allergy.pb.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_intensity.pb.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_type.pb.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/constants.dart';

String? validateDietType(DietType? value) {
  if (value == null) {
    return AppConfig.requiredDietType;
  }
  return null;
}

String? validateDietGoal(String? value) {
  final weight = double.tryParse(value ?? '');
  if (weight == null ||
      weight < Constants.minWeight ||
      weight > Constants.maxWeight) {
    return '${AppConfig.dietGoalShouldBeBetween} [${Constants.minWeight}, ${Constants.maxWeight}]';
  }
  return null;
}

String? validateDietIntensity(DietIntensity? value) {
  if (value == null) {
    return AppConfig.requiredDietIntensity;
  }
  return null;
}
