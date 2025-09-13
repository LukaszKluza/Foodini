import 'package:frontend/config/app_config.dart';

String? validateAge(int? value) {
    if (value == null) {
      return AppConfig.requiredAge;
    }
    return null;
  }

  String? validateCountry(String? value, String? selectedCountry) {
    if (selectedCountry == null || selectedCountry.isEmpty) {
      return AppConfig.requiredCountry;
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppConfig.requiredName;
    }
    if (value.length < 2 ||
        value.length > 50 ||
        !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return AppConfig.provideCorrectName;
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppConfig.requiredEmail;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return AppConfig.invalidEmail;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConfig.requiredPassword;
    }
    if (value.length < AppConfig.minPasswordLength) {
      return AppConfig.minimalPasswordLength;
    }
    if (value.length > AppConfig.maxPasswordLength) {
      return AppConfig.maximalPasswordLength;
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return AppConfig.passwordComplexityError;
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return AppConfig.requiredPasswordConfirmation;
    }
    if (value != originalPassword) {
      return AppConfig.samePasswords;
    }
    return null;
  }