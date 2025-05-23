import 'package:flutter/material.dart';
import 'package:frontend/assets/calories_prediction_enums/activity_level.pb.dart';
import 'package:frontend/assets/calories_prediction_enums/sleep_quality.pb.dart';
import 'package:frontend/assets/calories_prediction_enums/stress_level.pb.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_intensity.pb.dart';

import '../assets/diet_preferences_enums/allergy.pbenum.dart';
import '../assets/diet_preferences_enums/diet_type.pbenum.dart';

class AppConfig {
  // Numbers
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 64;
  static const int redirectionDelay = 100;

  //Texts
  static const String foodini = 'Foodini';
  static const String myAccount = 'My Account';
  static const String changePassword = 'Change password';
  static const String deleteAccount = 'Delete account';
  static const String home = 'Home';
  static const String homePage = 'Foodini Home Page';
  static const String welcome = 'Welcome in Foodini';

  static const String successfullyRegistered = 'Registered successfully';
  static const String requiredName = 'Name is required';
  static const String provideCorrectName = 'Provide correct name';
  static const String requiredCountry = 'Select your country';
  static const String requiredEmail = 'E-mail is required';
  static const String requiredPassword = 'Password is required';
  static const String requiredPasswordConfirmation =
      'Password confirmation is required';
  static const String samePasswords = 'Passwords must be the same';
  static const String minimalPasswordLength =
      'Password must have at least $minPasswordLength characters';
  static const String maximalPasswordLength =
      'Password must have no more than $maxPasswordLength characters';
  static const String passwordComplexityError =
      'Password must contain letters (capital and lowercase) and numbers';
  static const String invalidEmail = 'Enter valid e-mail';
  static const String registration = 'Registration';
  static const String register = 'Register';
  static const String account = 'Account';
  static const String alreadyHaveAnAccount = 'Already have an account? Login';
  static const String firstName = 'First name';
  static const String lastName = 'Last name';
  static const String country = 'Country';
  static const String email = 'E-mail';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm password';
  static const String newPassword = 'New password';
  static const String registrationFailed = 'Registration failed';

  static const String login = 'Login';
  static const String dontHaveAccount = 'Do not have an account';
  static const String forgotPassword = 'Forgot my password';
  static const String successfullyLoggedIn = 'Successfully logged in';
  static const String successfullyLoggedOut = 'Account logged out successfully';
  static const String successfullyDeletedAccount =
      'Account deleted successfully';
  static const String accountActivatedSuccessfully =
      'Account has been activated successfully';
  static const String accountHasNotBeenConfirmed =
      'Your account has not been confirmed.';
  static const String successfullyResendEmailVerification =
      'Email account verification send successfully';
  static const String sendVerificationEmailAgain =
      'Send verification email again';
  static const String accountDeletionInformation =
      'Are you sure you want to delete your account? This action cannot be undone.';
  static const String confirmAccountDeletion = 'Confirm Account Deletion';
  static const String delete = 'Delete';
  static const String cancel = 'Cancel';
  static const String ok = 'Ok';
  static const String loginFailed = 'Login failed';
  static const String logout = 'Logout';
  static const String somethingWentWrong = 'Something went wrong';
  static const String checkAndConfirmEmailAddress =
      'Check and confirm your email address';
  static const String checkEmailAddressToSetNewPassword =
      'Check your email address to set new password';
  static const String passwordSuccessfullyChanged =
      'Password successfully changed';
  static const String wrongChangePasswordUrl =
      "You can't access change password form";

  static const String dietPreferences = 'Diet preferences';

  static const String dietType = 'Diet type';
  static const String requiredDietType = 'Diet type is required';
  static const Map<DietType, String> dietTypeLabels = {
    DietType.FAT_LOSS: 'Fat Loss',
    DietType.MUSCLE_GAIN: 'Muscle Gain',
    DietType.WEIGHT_MAINTENANCE: 'Weight Maintenance',
    DietType.VEGETARIAN: 'Vegetarian',
    DietType.VEGAN: 'Vegan',
    DietType.KETO: 'Keto',
  };

  static const String allergies = 'Allergies';
  static const Map<Allergy, String> allergyLabels = {
    Allergy.GLUTEN: 'Gluten',
    Allergy.PEANUTS: 'Peanuts',
    Allergy.LACTOSE: 'Lactose',
    Allergy.FISH: 'Fish',
    Allergy.SOY: 'Soy',
    Allergy.WHEAT: 'Wheat',
    Allergy.CELERY: 'Celery',
    Allergy.SULPHITES: 'Sulphites',
    Allergy.LUPIN: 'Lupin',
  };

  static const String dietGoal = 'Diet goal';
  static const String enterYourDietGoal = 'Enter your diet goal';
  static const String weightKg = 'Weight (kg)';
  static const double minWeight = 20;
  static const double maxWeight = 160;
  static const String dietGoalShouldBeBetween = 'Diet goal should be between';
  static const String kg = 'kg';

  static const String mealsPerDay = 'Meals per day';
  static const int maxMealsPerDay = 6;

  static const String dietIntensity = 'Diet intensity';
  static const String requiredDietIntensity = 'Diet intensity is required';
  static const Map<DietIntensity, String> dietIntensityLabels = {
    DietIntensity.SLOW: 'Slow',
    DietIntensity.MEDIUM: 'Medium',
    DietIntensity.FAST: 'Fast',
  };

  static const String caloriesPrediction = 'Calories prediction';

  static const String activityLevel = 'Activity level';
  static const String requiredActivityLevel = 'Activity level is required';
  static const Map<ActivityLevel, String> activityLevelLabels = {
    ActivityLevel.VERY_LOW: 'Very Low (1–2 days a week or less)',
    ActivityLevel.LIGHT: 'Low (2–3 days a week)',
    ActivityLevel.MODERATE: 'Moderate (3–4 days a week)',
    ActivityLevel.ACTIVE: 'Active (5–6 days a week)',
    ActivityLevel.VERY_ACTIVE: ' Very Active (daily activity)',
  };

  static const String stressLevel = 'Stress level';
  static const String requiredStressLevel = 'Stress level is required';
  static const Map<StressLevel, String> stressLevelLabels = {
    StressLevel.LOW: 'Low',
    StressLevel.MEDIUM: 'Medium',
    StressLevel.HIGH: 'High',
    StressLevel.EXTREME: 'Extreme',
  };

  static const String sleepQuality = 'Sleep quality';
  static const String requiredSleepQuality = 'Sleep quality is required';
  static const Map<SleepQuality, String> stressSleepQualityLabels = {
    SleepQuality.POOR: 'Poor',
    SleepQuality.FAIR: 'Fair',
    SleepQuality.GOOD: 'Good',
    SleepQuality.EXCELLENT: 'Excellent',
  };

  static const String advancedBodyParameters = "Advance body parameters";

  static const String musclePercentage = "Muscle percentage";
  static const String enterMusclePercentage = 'Enter your muscle %';
  static const String musclePercentageMustBeBetween =
      'Muscle % must be between';

  static const String waterPercentage = "Water percentage";
  static const String enterWaterPercentage = 'Enter your water percentage';
  static const String waterPercentageShouldBeBetween = 'Water % should be %';

  static const String fatPercentage = "Fat percentage";
  static const String enterFatPercentage = 'Enter your fat percentage';
  static const String fatPercentageShouldBeBetween = 'Fat % should be %';

  static const String generateWeeklyDiet = 'Generate weekly diet';

  // URLs
  static const String baseUrl = 'http://127.0.0.1:8000/v1';

  // Mobile app url
  // static const String baseUrl = 'http://10.0.2.2:8000/v1';
  static const String registerUrl = '$baseUrl/users/register';
  static const String loginUrl = '$baseUrl/users/login';
  static const String logoutUrl = '$baseUrl/users/logout';
  static const String getUserUrl = '$baseUrl/users/';
  static const String resendVerificationEmailUrl =
      '$baseUrl/users/confirm/resend-verification-new-account';
  static const String deleteUrl = '$baseUrl/users/delete';
  static const String changePasswordUrl =
      '$baseUrl/users/reset-password/request';
  static const String confirmNewPasswordUrl =
      '$baseUrl/users/confirm/new-password';
  static const String refreshTokensUrl = '$baseUrl/users/refresh-tokens';

  //Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 32,
    fontStyle: FontStyle.italic,
  );
  static const TextStyle errorStyle = TextStyle(color: Colors.red);
  static const TextStyle warningStyle = TextStyle(color: Colors.orange);
  static const TextStyle successStyle = TextStyle(color: Colors.green);
}
