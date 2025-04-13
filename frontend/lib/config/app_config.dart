import 'package:flutter/material.dart';

class AppConfig {
  // Numbers
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 64;

  //Texts
  static const String foodini = 'Foodini';
  static const String myAccout = 'My Account';
  static const String changePassword = 'Change password';
  static const String home = 'Home';
  static const String homePage = 'Foodini Home Page';
  static const String welcome = 'Welcome in Foodini';

  static const String succesfullyRegistered = 'Registered successfully';
  static const String requiredName = 'Name is required';
  static const String provideCorrectName = 'Provide correct name';
  static const String requiredAge = 'Select your age';
  static const String requiredCountry = 'Select your country';
  static const String requiredEmail = 'E-mail is required';
  static const String requiredPassword = 'Password is required';
  static const String requiredPasswordConfirmation =
      'Password confirmation is required';
  static const String samePasswords = 'Passwords must be the same';
  static const String minimalPasswordLegth =
      'Password must have at least $minPasswordLength characters';
  static const String maximalPasswordLegth =
      'Password must have no more than $maxPasswordLength characters';
  static const String passwordComplexityError =
      'Password must contain letters (capital and lowercase) and numbers';
  static const String invalidEmail = 'Enter valid e-mail';
  static const String registration = 'Registration';
  static const String register = 'Register';
  static const String alreadyHaveAnAccount = 'Already have an account? Login';
  static const String firstName = 'First name';
  static const String lastName = 'Last name';
  static const String age = 'Age';
  static const String country = 'Country';
  static const String email = 'E-mail';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm password';
  static const String newPassword = 'New password';
  static const String registrationFailed = 'Registration failed';

  static const String login = 'Login';
  static const String dontHaveAccount = 'Do not have an account';
  static const String successfullyLoggedIn = 'Succesfully logged in';
  static const String loginFailed = 'Login failed';
  static const String logout = 'Logout';
  static const String somethingWentWrong = 'Somethin went wrong';
  static const String checkAndConfirmEmailAddress =
      'Check and confirm your email address';

  //Lists
  static final List<int> ages = List.generate(109, (index) => index + 12);

  // URLs
  static const String baseUrl = 'http://127.0.0.1:8000/v1';
  static const String registerUrl = '$baseUrl/users/register';
  static const String loginUrl = '$baseUrl/users/login';
  static const String logoutUrl = '$baseUrl/users/logout';
  static const String changePasswordUrl = '$baseUrl/reset-password/request';

  //Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 32,
    fontStyle: FontStyle.italic,
  );
  static const TextStyle errorStyle = TextStyle(color: Colors.red);
}
