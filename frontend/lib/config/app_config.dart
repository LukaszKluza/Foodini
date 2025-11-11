import 'package:flutter/cupertino.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/meal_status.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/models/user_details/activity_level.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_style.dart';
import 'package:frontend/models/user_details/diet_type.dart';
import 'package:frontend/models/user_details/dietary_restriction.dart';
import 'package:frontend/models/user_details/gender.dart';
import 'package:frontend/models/user_details/sleep_quality.dart';
import 'package:frontend/models/user_details/stress_level.dart';

class AppConfig {
  static Map<DietType, String> dietTypeLabels(BuildContext context) => {
    DietType.fatLoss: AppLocalizations.of(context)!.dietType_FatLoss,
    DietType.muscleGain: AppLocalizations.of(context)!.dietType_MuscleGain,
    DietType.weightMaintenance:
        AppLocalizations.of(context)!.dietType_WeightMaintenance,
  };

  static Map<DietStyle, String> dietStyleLabels(BuildContext context) => {
    DietStyle.vegetarian: AppLocalizations.of(context)!.dietStyle_Vegetarian,
    DietStyle.vegan: AppLocalizations.of(context)!.dietStyle_Vegan,
    DietStyle.keto: AppLocalizations.of(context)!.dietStyle_Keto,
  };

  static Map<DietaryRestriction, String> dietaryRestrictionLabels(BuildContext context) => {
    DietaryRestriction.gluten: AppLocalizations.of(context)!.dietaryRestriction_Gluten,
    DietaryRestriction.peanuts: AppLocalizations.of(context)!.dietaryRestriction_Peanuts,
    DietaryRestriction.lactose: AppLocalizations.of(context)!.dietaryRestriction_Lactose,
    DietaryRestriction.fish: AppLocalizations.of(context)!.dietaryRestriction_Fish,
    DietaryRestriction.soy: AppLocalizations.of(context)!.dietaryRestriction_Soy,
    DietaryRestriction.wheat: AppLocalizations.of(context)!.dietaryRestriction_Wheat,
    DietaryRestriction.celery: AppLocalizations.of(context)!.dietaryRestriction_Celery,
    DietaryRestriction.sulphites: AppLocalizations.of(context)!.dietaryRestriction_Sulphites,
    DietaryRestriction.lupin: AppLocalizations.of(context)!.dietaryRestriction_Lupin
  };

  static Map<DietIntensity, String> dietIntensityLabels(
    BuildContext context,
  ) => {
    DietIntensity.slow: AppLocalizations.of(context)!.dietIntensity_Slow,
    DietIntensity.medium: AppLocalizations.of(context)!.dietIntensity_Medium,
    DietIntensity.fast: AppLocalizations.of(context)!.dietIntensity_Fast,
  };

  static Map<ActivityLevel, String> activityLevelLabels(
    BuildContext context,
  ) => {
    ActivityLevel.veryLow: AppLocalizations.of(context)!.activityLevel_VeryLow,
    ActivityLevel.light: AppLocalizations.of(context)!.activityLevel_Light,
    ActivityLevel.moderate:
        AppLocalizations.of(context)!.activityLevel_Moderate,
    ActivityLevel.active: AppLocalizations.of(context)!.activityLevel_Active,
    ActivityLevel.veryActive:
        AppLocalizations.of(context)!.activityLevel_VeryActive,
  };

  static Map<StressLevel, String> stressLevelLabels(BuildContext context) => {
    StressLevel.low: AppLocalizations.of(context)!.stressLevel_Low,
    StressLevel.medium: AppLocalizations.of(context)!.stressLevel_Medium,
    StressLevel.high: AppLocalizations.of(context)!.stressLevel_High,
    StressLevel.extreme: AppLocalizations.of(context)!.stressLevel_Extreme,
  };

  static Map<SleepQuality, String> sleepQualityLabels(BuildContext context) => {
    SleepQuality.poor: AppLocalizations.of(context)!.sleepQuality_Poor,
    SleepQuality.fair: AppLocalizations.of(context)!.sleepQuality_Fair,
    SleepQuality.good: AppLocalizations.of(context)!.sleepQuality_Good,
    SleepQuality.excellent:
        AppLocalizations.of(context)!.sleepQuality_Excellent,
  };

  static Map<Gender, String> genderLabels(BuildContext context) => {
    Gender.male: AppLocalizations.of(context)!.gender_Male,
    Gender.female: AppLocalizations.of(context)!.gender_Female,
  };

  static Map<MealType, String> mealTypeLabels(BuildContext context) => {
    MealType.breakfast: AppLocalizations.of(context)!.breakfast,
    MealType.morningSnack: AppLocalizations.of(context)!.morningSnack,
    MealType.lunch: AppLocalizations.of(context)!.lunch,
    MealType.afternoonSnack: AppLocalizations.of(context)!.afternoonSnack,
    MealType.dinner: AppLocalizations.of(context)!.dinner,
    MealType.eveningSnack: AppLocalizations.of(context)!.eveningSnack,
  };

  static Map<MealStatus, String> mealStatusLabels(BuildContext context) => {
    MealStatus.toEat: AppLocalizations.of(context)!.toEat,
    MealStatus.pending: AppLocalizations.of(context)!.pending,
    MealStatus.eaten: AppLocalizations.of(context)!.eaten,
    MealStatus.skipped: AppLocalizations.of(context)!.skipped,
  };
}
