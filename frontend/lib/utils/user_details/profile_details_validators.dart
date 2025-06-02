import 'package:flutter/cupertino.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/gender.dart';

String? validateGender(Gender? value, BuildContext context) {
  if (value == null) {
    return AppLocalizations.of(context)!.requiredGender;
  }
  return null;
}

String? validateWeight(String? value, BuildContext context) {
  final weight = double.tryParse(value ?? '');
  if (weight == null ||
      weight < Constants.minWeight ||
      weight > Constants.maxWeight) {
    return '${AppLocalizations.of(context)!.weightShouldBeBetween} [${Constants.minWeight}, ${Constants.maxWeight}]';
  }
  return null;
}

String? validateHeight(String? value, BuildContext context) {
  final height = double.tryParse(value ?? '');
  if (height == null ||
      height < Constants.minHeight ||
      height > Constants.maxHeight) {
    return '${AppLocalizations.of(context)!.heightShouldBeBetween} [${Constants.minHeight}, ${Constants.maxHeight}]';
  }
  return null;
}
