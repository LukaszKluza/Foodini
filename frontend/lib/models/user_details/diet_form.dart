import 'package:frontend/models/user_details/activity_level.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_type.dart';
import 'package:frontend/models/user_details/dietary_restriction.dart';
import 'package:frontend/models/user_details/gender.dart';
import 'package:frontend/models/user_details/sleep_quality.dart';
import 'package:frontend/models/user_details/stress_level.dart';

class DietForm {
  final Gender gender;
  final double height;
  final double weight;
  final DateTime dateOfBirth;
  final DietType dietType;
  final List<DietaryRestriction> dietaryRestrictions;
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
    required this.dietaryRestrictions,
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
    'gender': gender.nameStr,
    'height_cm': height,
    'weight_kg': weight,
    'date_of_birth': dateOfBirth.toIso8601String(),
    'diet_type': dietType.nameStr,
    'dietary_restrictions': dietaryRestrictions.map((a) => a.nameStr).toList(),
    'diet_goal_kg': dietGoal,
    'meals_per_day': mealsPerDay,
    'diet_intensity': dietIntensity.nameStr,
    'activity_level': activityLevel.nameStr,
    'stress_level': stressLevel.nameStr,
    'sleep_quality': sleepQuality.nameStr,
    'muscle_percentage': musclePercentage,
    'fat_percentage': fatPercentage,
    'water_percentage': waterPercentage,
  };

  factory DietForm.fromJson(Map<String, dynamic> json) {
    return DietForm(
      gender: Gender.fromJson(json['gender']),
      height: (json['height_cm'] as num).toDouble(),
      weight: (json['weight_kg'] as num).toDouble(),
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      dietType: DietType.fromJson(json['diet_type']),
      dietaryRestrictions:
          (json['dietary_restrictions'] as List<dynamic>)
              .map((e) => DietaryRestriction.fromJson(e))
              .toList(),
      dietGoal: (json['diet_goal_kg'] as num).toDouble(),
      mealsPerDay: json['meals_per_day'] as int,
      dietIntensity: DietIntensity.fromJson(json['diet_intensity']),
      activityLevel: ActivityLevel.fromJson(json['activity_level']),
      stressLevel: StressLevel.fromJson(json['stress_level']),
      sleepQuality: SleepQuality.fromJson(json['sleep_quality']),
      musclePercentage: (json['muscle_percentage'] as num?)?.toDouble(),
      fatPercentage: (json['fat_percentage'] as num?)?.toDouble(),
      waterPercentage: (json['water_percentage'] as num?)?.toDouble(),
    );
  }
}
