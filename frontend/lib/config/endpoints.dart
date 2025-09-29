class Endpoints {
  static const String baseUrl = String.fromEnvironment('baseUrl');
  static const String login = '$baseUrl/users/login';
  static const String logout = '$baseUrl/users/logout';
  static const String users = '$baseUrl/users/';
  static const String resendVerificationEmail =
      '$baseUrl/users/confirm/resend-verification-new-account';
  static const String changePassword = '$baseUrl/users/reset-password/request';
  static const String changeLanguage = '$baseUrl/users/language';
  static const String confirmNewPassword =
      '$baseUrl/users/confirm/new-password';
  static const String refreshTokens = '$baseUrl/users/refresh-tokens';
  static const String dietPreferences = '$baseUrl/user_details';
  static const String mealRecipe = '$baseUrl/diet-prediction/meal-recipe';
  static const String dietPrediction = '$baseUrl/diet_prediction';
}