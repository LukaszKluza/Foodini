import 'package:frontend/models/user_details/activity_level.dart';
import 'package:frontend/models/user_details/allergy.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_type.dart';
import 'package:frontend/models/user_details/gender.dart';
import 'package:frontend/models/user_details/sleep_quality.dart';
import 'package:frontend/models/user_details/stress_level.dart';

class DietForm {
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

  DietForm({
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

  Map<String, dynamic> toJson() => {
  'gender': gender.value,
  'height': height,
  'weight': weight,
  'date_of_birth': dateOfBirth.toIso8601String(),
  'diet_type': dietType.value,
  'allergies': allergies.map((a) => a.value).toList(),
  'diet_goal': dietGoal,
  'meals_per_day': mealsPerDay,
  'diet_intensity': dietIntensity.value,
  'activity_level': activityLevel.value,
  'stress_level': stressLevel.value,
  'sleep_quality': sleepQuality.value,
  'muscle_percentage': musclePercentage,
  'fat_percentage': fatPercentage,
  'water_percentage': waterPercentage,
};
}
