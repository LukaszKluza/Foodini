import 'package:flutter/cupertino.dart';

import 'package:frontend/config/constants.dart';
import 'package:frontend/l10n/app_localizations.dart';

String? validateCountry(String? value, BuildContext context) {
  if (value == null || value.isEmpty) {
    return AppLocalizations.of(context)!.requiredCountry;
  }
  return null;
}

String? validateName(String? value, BuildContext context) {
  if (value == null || value.isEmpty) {
    return AppLocalizations.of(context)!.requiredName;
  }
  if (value.length < 2 ||
      value.length > 50 ||
      !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
    return AppLocalizations.of(context)!.provideCorrectName;
  }
  return null;
}

String? validateLastname(String? value, BuildContext context) {
  if (value == null || value.isEmpty) {
    return AppLocalizations.of(context)!.requiredLastname;
  }
  if (value.length < 2 ||
      value.length > 50 ||
      !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
    return AppLocalizations.of(context)!.provideCorrectLastname;
  }
  return null;
}

String? validateEmail(String? value, BuildContext context) {
  if (value == null || value.isEmpty) {
    return AppLocalizations.of(context)!.requiredEmail;
  }
  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
    return AppLocalizations.of(context)!.invalidEmail;
  }
  return null;
}

String? validatePassword(String? value, BuildContext context) {
  if (value == null || value.isEmpty) {
    return AppLocalizations.of(context)!.requiredPassword;
  }
  if (value.length < Constants.minPasswordLength ||
      value.length > Constants.maxPasswordLength) {
    return '${AppLocalizations.of(context)!.passwordLengthMustBeBetween} (${Constants.minPasswordLength}, ${Constants.maxPasswordLength})';
  }
  if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
    return AppLocalizations.of(context)!.passwordComplexityError;
  }
  return null;
}

String? validateConfirmPassword(
  String? value,
  String originalPassword,
  BuildContext context,
) {
  if (value == null || value.isEmpty) {
    return AppLocalizations.of(context)!.requiredPasswordConfirmation;
  }
  if (value != originalPassword) {
    return AppLocalizations.of(context)!.samePasswords;
  }
  return null;
}
