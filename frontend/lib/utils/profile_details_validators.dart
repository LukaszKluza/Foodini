import 'package:frontend/assets/profile_details/gender.pbenum.dart';
import 'package:frontend/config/app_config.dart';

String? validateGender(Gender? value) {
  if (value == null) {
    return AppConfig.requiredGender;
  }
  return null;
}

String? validateWeight(String? value) {
  final weight = double.tryParse(value ?? '');
  if (weight == null ||
      weight < AppConfig.minWeight ||
      weight > AppConfig.maxWeight) {
    return '${AppConfig.weightShouldBeBetween} ${AppConfig.minWeight} and ${AppConfig.maxWeight}';
  }
  return null;
}

String? validateHeight(String? value) {
  final height = double.tryParse(value ?? '');
  if (height == null ||
      height < AppConfig.minHeight ||
      height > AppConfig.maxHeight) {
    return '${AppConfig.heightShouldBeBetween} ${AppConfig.minHeight} and ${AppConfig.maxHeight}';
  }
  return null;
}
