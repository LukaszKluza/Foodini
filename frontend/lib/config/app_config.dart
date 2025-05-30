import 'package:flutter/cupertino.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/allergy.dart';
import 'package:frontend/models/user_details/activity_level.dart';
import 'package:frontend/models/user_details/sleep_quality.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/stress_level.dart';
import 'package:frontend/models/user_details/diet_type.dart';

class AppConfig {
  static Map<DietType, String> dietTypeLabels(BuildContext context) => {
    DietType.fatLoss: AppLocalizations.of(context)!.dietType_fatLoss,
    DietType.muscleGain: AppLocalizations.of(context)!.dietType_muscleGain,
    DietType.weightMaintenance:
        AppLocalizations.of(context)!.dietType_weightMaintenance,
    DietType.vegetarian: AppLocalizations.of(context)!.dietType_vegetarian,
    DietType.vegan: AppLocalizations.of(context)!.dietType_vegan,
    DietType.keto: AppLocalizations.of(context)!.dietType_keto,
  };

  static Map<Allergy, String> allergyLabels(BuildContext context) => {
    Allergy.gluten: AppLocalizations.of(context)!.allergy_gluten,
    Allergy.peanuts: AppLocalizations.of(context)!.allergy_peanuts,
    Allergy.lactose: AppLocalizations.of(context)!.allergy_lastose,
    Allergy.fish: AppLocalizations.of(context)!.allergy_fish,
    Allergy.soy: AppLocalizations.of(context)!.allergy_soy,
    Allergy.wheat: AppLocalizations.of(context)!.allergy_wheat,
    Allergy.celery: AppLocalizations.of(context)!.allergy_celery,
    Allergy.sulphites: AppLocalizations.of(context)!.allergy_sulphites,
    Allergy.lupin: AppLocalizations.of(context)!.allergy_lupin,
  };

  static Map<DietIntensity, String> dietIntensityLabels(
    BuildContext context,
  ) => {
    DietIntensity.slow: AppLocalizations.of(context)!.dietIntensity_slow,
    DietIntensity.medium: AppLocalizations.of(context)!.dietIntensity_medium,
    DietIntensity.fast: AppLocalizations.of(context)!.dietIntensity_fast,
  };

  static Map<ActivityLevel, String> activityLevelLabels(
    BuildContext context,
  ) => {
    ActivityLevel.veryLow: AppLocalizations.of(context)!.activityLevel_veryLow,
    ActivityLevel.light: AppLocalizations.of(context)!.activityLevel_light,
    ActivityLevel.moderate:
        AppLocalizations.of(context)!.activityLevel_moderate,
    ActivityLevel.active: AppLocalizations.of(context)!.activityLevel_active,
    ActivityLevel.veryActive:
        AppLocalizations.of(context)!.activityLevel_veryActive,
  };

  static Map<StressLevel, String> stressLevelLabels(BuildContext context) => {
    StressLevel.low: AppLocalizations.of(context)!.stressLevel_low,
    StressLevel.medium: AppLocalizations.of(context)!.stressLevel_medium,
    StressLevel.high: AppLocalizations.of(context)!.stressLevel_high,
    StressLevel.extreme: AppLocalizations.of(context)!.stressLevel_extreme,
  };

  static Map<SleepQuality, String> sleepQualityLabels(BuildContext context) => {
    SleepQuality.poor: AppLocalizations.of(context)!.sleepQuality_poor,
    SleepQuality.fair: AppLocalizations.of(context)!.sleepQuality_fair,
    SleepQuality.good: AppLocalizations.of(context)!.sleepQuality_good,
    SleepQuality.excellent:
        AppLocalizations.of(context)!.sleepQuality_excelent,
  };
}
