class Endpoints {
  static const String baseUrl = String.fromEnvironment('baseUrl');
  // users
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

  // user-details
  static const String dietPreferences = '$baseUrl/user-details';
  static const String userCaloriesPrediction = '$baseUrl/calories-prediction';

  // diet-prediction
  static const String generateMealPlan = '$baseUrl/diet-generation/generate-meal-plan';

  // daily-summary
  static const String dailySummary = '$baseUrl/daily-summary';
  static const String dailySummaryMeals = '$baseUrl/daily-summary/meals';
  static const String dailySummaryMacros = '$baseUrl/daily-summary/macros';
  static const String customMeal = '$baseUrl/daily-summary/meals/custom';

  // meals
  static const String meal = '$baseUrl/meals';
  static const String mealRecipe = '$baseUrl/meals/meal-recipes';
  static const String mealIconInfo = '$baseUrl/meals/meal-icon';

  // static
  static const String mealIcon= '$baseUrl/static/meals-icon';
}