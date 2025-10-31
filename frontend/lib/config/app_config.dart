import 'package:flutter/cupertino.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/meal_status.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/models/user_details/activity_level.dart';
import 'package:frontend/models/user_details/allergy.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_type.dart';
import 'package:frontend/models/user_details/gender.dart';
import 'package:frontend/models/user_details/sleep_quality.dart';
import 'package:frontend/models/user_details/stress_level.dart';

class AppConfig {
  static Map<DietType, String> dietTypeLabels(BuildContext context) => {
    DietType.fatLoss: AppLocalizations.of(context)!.dietType_FatLoss,
    DietType.muscleGain: AppLocalizations.of(context)!.dietType_MuscleGain,
    DietType.weightMaintenance:
        AppLocalizations.of(context)!.dietType_WeightMaintenance,
    DietType.vegetarian: AppLocalizations.of(context)!.dietType_Vegetarian,
    DietType.vegan: AppLocalizations.of(context)!.dietType_Vegan,
    DietType.keto: AppLocalizations.of(context)!.dietType_Keto,
  };

  static Map<Allergy, String> allergyLabels(BuildContext context) => {
    Allergy.gluten: AppLocalizations.of(context)!.allergy_Gluten,
    Allergy.peanuts: AppLocalizations.of(context)!.allergy_Peanuts,
    Allergy.lactose: AppLocalizations.of(context)!.allergy_Lactose,
    Allergy.fish: AppLocalizations.of(context)!.allergy_Fish,
    Allergy.soy: AppLocalizations.of(context)!.allergy_Soy,
    Allergy.wheat: AppLocalizations.of(context)!.allergy_Wheat,
    Allergy.celery: AppLocalizations.of(context)!.allergy_Celery,
    Allergy.sulphites: AppLocalizations.of(context)!.allergy_Sulphites,
    Allergy.lupin: AppLocalizations.of(context)!.allergy_Lupin,
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
