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
    return '${AppLocalizations.of(context)!.valueOfCaloriesShouldBeBetween} [0, ${Constants.maxCaloriesValue}]';
  }
  return null;
}

String? validateWeight(String? rawValue, BuildContext context) {
  final value = int.tryParse(rawValue ?? '');
  if (value == null ||
      value < 0 ||
      value > Constants.maxWeightValue) {
    return '${AppLocalizations.of(context)!.valueOfWeightShouldBeBetween} [1, ${Constants.maxWeightValue}]';
  }
  return null;
}

String? validateBarcode(String? barcode, BuildContext context) {
  if (barcode == null || barcode.isEmpty) {
    return AppLocalizations.of(context)!.barcodeCannotBeEmpty;
  }

  if (barcode.length != Constants.barcodeLength) {
    return '${AppLocalizations.of(context)!.barcodeMustBeLength} ${Constants.barcodeLength}';
  }

  if (!RegExp(r'^\d+$').hasMatch(barcode)) {
    return AppLocalizations.of(context)!.barcodeMustContainOnlyDigits;
  }
  return null;
}
