import 'package:frontend/assets/calories_prediction_enums/activity_level.pb.dart';
import 'package:frontend/assets/calories_prediction_enums/sleep_quality.pb.dart';
import 'package:frontend/assets/calories_prediction_enums/stress_level.pb.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_intensity.pb.dart';

import 'package:frontend/assets/diet_preferences_enums/allergy.pbenum.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_type.pbenum.dart';

class AppConfig {
  //Texts
  static const String checkEmailAddressToSetNewPassword =
      'Check your email address to set new password';
  static const String passwordSuccessfullyChanged =
      'Password successfully changed';

  static const Map<DietType, String> dietTypeLabels = {
    DietType.FAT_LOSS: 'Fat Loss',
    DietType.MUSCLE_GAIN: 'Muscle Gain',
    DietType.WEIGHT_MAINTENANCE: 'Weight Maintenance',
    DietType.VEGETARIAN: 'Vegetarian',
    DietType.VEGAN: 'Vegan',
    DietType.KETO: 'Keto',
  };

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

  static const Map<DietIntensity, String> dietIntensityLabels = {
    DietIntensity.SLOW: 'Slow',
    DietIntensity.MEDIUM: 'Medium',
    DietIntensity.FAST: 'Fast',
  };


  static const Map<ActivityLevel, String> activityLevelLabels = {
    ActivityLevel.VERY_LOW: 'Very Low (1–2 days a week or less)',
    ActivityLevel.LIGHT: 'Low (2–3 days a week)',
    ActivityLevel.MODERATE: 'Moderate (3–4 days a week)',
    ActivityLevel.ACTIVE: 'Active (5–6 days a week)',
    ActivityLevel.VERY_ACTIVE: 'Very Active (daily activity)',
  };

  static const Map<StressLevel, String> stressLevelLabels = {
    StressLevel.LOW: 'Low',
    StressLevel.MEDIUM: 'Medium',
    StressLevel.HIGH: 'High',
    StressLevel.EXTREME: 'Extreme',
  };

  static const Map<SleepQuality, String> sleepQualityLabels = {
    SleepQuality.POOR: 'Poor',
    SleepQuality.FAIR: 'Fair',
    SleepQuality.GOOD: 'Good',
    SleepQuality.EXCELLENT: 'Excellent',
  };
}
