import 'package:frontend/assets/profile_details/gender.pbenum.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/constants.dart';

String? validateGender(Gender? value) {
  if (value == null) {
    return AppConfig.requiredGender;
  }
  return null;
}

String? validateWeight(String? value) {
  final weight = double.tryParse(value ?? '');
  if (weight == null ||
      weight < Constants.minWeight ||
      weight > Constants.maxWeight) {
    return '${AppConfig.weightShouldBeBetween} [${Constants.minWeight}, ${Constants.maxWeight}]';
  }
  return null;
}

String? validateHeight(String? value) {
  final height = double.tryParse(value ?? '');
  if (height == null ||
      height < Constants.minHeight ||
      height > Constants.maxHeight) {
    return '${AppConfig.heightShouldBeBetween} [${Constants.minHeight}, ${Constants.maxHeight}]';
  }
  return null;
}
