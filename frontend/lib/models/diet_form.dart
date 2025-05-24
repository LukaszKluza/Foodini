import 'package:frontend/assets/calories_prediction_enums/activity_level.pbenum.dart';
import 'package:frontend/assets/calories_prediction_enums/sleep_quality.pbenum.dart';
import 'package:frontend/assets/calories_prediction_enums/stress_level.pbenum.dart';
import 'package:frontend/assets/diet_preferences_enums/allergy.pbenum.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_intensity.pbenum.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_type.pbenum.dart';
import 'package:frontend/assets/profile_details/gender.pbenum.dart';

class DietFormData {
  final Gender gender;
  final double height;
  final double weight;
  final DateTime dateOfBirth;
  final DietType dietType;
  final List<Allergy> allergies;
  final double dietGoal;
  final int mealsPerDay;
  final DietIntensity dietIntensity;
  final ActivityLevel activityLevel;
  final StressLevel stressLevel;
  final SleepQuality sleepQuality;
  final double? musclePercentage;
  final double? fatPercentage;
  final double? waterPercentage;

  DietFormData({
    required this.gender,
    required this.height,
    required this.weight,
    required this.dateOfBirth,
    required this.dietType,
    required this.allergies,
    required this.dietGoal,
    required this.mealsPerDay,
    required this.dietIntensity,
    required this.activityLevel,
    required this.stressLevel,
    required this.sleepQuality,
    this.musclePercentage,
    this.fatPercentage,
    this.waterPercentage,
  });
}
