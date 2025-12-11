import 'package:frontend/models/user_details/cooking_skills.dart';
import 'package:frontend/models/user_details/daily_budget.dart';

class Constants {
  static const String pipe = '|';

  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 64;
  static const int redirectionDelay = 200;
  static const double minWeight = 20;
  static const double maxWeight = 160;
  static const double defaultWeight = 65;
  static const double minHeight = 60;
  static const double maxHeight = 230;
  static const double defaultHeight = 175;
  static const int minMealsPerDay = 3;
  static const int maxMealsPerDay = 6;
  static const int defaultMealsPerDay = 4;
  static const DailyBudget defaultDailyBudget = DailyBudget.medium;
  static const CookingSkills defaultCookingSkills = CookingSkills.advanced;
  static const String mainFoodiniIcon = 'assets/icons/icon_14.png';

  static const double minimumMusclePercentage = 0;
  static const double maximumMusclePercentage = 60;
  static const double defaultMusclePercentage = 25;
  static const double minimumWaterPercentage = 30;
  static const double maximumWaterPercentage = 80;
  static const double defaultWaterPercentage = 60;
  static const double minimumFatPercentage = 0;
  static const double maximumFatPercentage = 45;
  static const double defaultFatPercentage = 15;

  static const double horizontalPaddingRatio = 0.07;
  static const double screenWidth = 1170;
  static const double screenHeight = 2532;

  static const int proteinEstimator = 4;
  static const int fatEstimator = 9;
  static const int carbsEstimator = 4;

  static const int minNameLength = 2;
  static const int maxNameLength = 124;
  static const int barcodeLength = 13;
  static const int maxMacroValue = 1000;
  static const int maxCaloriesValue = 10_000;
  static const int maxWeightValue = 2250;
  static const String supportEmail = 'foodini.app.dev@gmail.com';
}
