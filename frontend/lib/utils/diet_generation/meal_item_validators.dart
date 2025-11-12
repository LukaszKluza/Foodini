import 'package:flutter/cupertino.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/l10n/app_localizations.dart';

String? validateMealItemName(String? name, BuildContext context) {
  if (name == null ||
      name.length < Constants.minNameLength ||
      name.length > Constants.maxNameLength) {
    return '${AppLocalizations.of(context)!.mealItemNameShouldBeBetween} [${Constants.minNameLength}, ${Constants.maxNameLength}]';
  }
  return null;
}

String? validateMacro(String? rawValue, BuildContext context) {
  final value = double.tryParse(rawValue ?? '');
  if (value == null ||
      value < 0 ||
      value > Constants.maxMacroValue) {
    return '${AppLocalizations.of(context)!.valueOfThisMacroShouldBeBetween} [0, ${Constants.maxMacroValue}]';
  }
  return null;
}

String? validateCalories(String? rawValue, BuildContext context) {
  final value = int.tryParse(rawValue ?? '');
  if (value == null ||
      value < 0 ||
      value > Constants.maxCaloriesValue) {
    return '${AppLocalizations.of(context)!.valueOfCaloriesMacroShouldBeBetween} [0, ${Constants.maxCaloriesValue}]';
  }
  return null;
}
