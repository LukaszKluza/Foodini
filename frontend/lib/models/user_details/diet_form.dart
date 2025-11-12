import 'package:frontend/models/user_details/activity_level.dart';
import 'package:frontend/models/user_details/cooking_skills.dart';
import 'package:frontend/models/user_details/daily_budget.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_style.dart';
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
  final DietStyle? dietStyle;
  final List<DietaryRestriction> dietaryRestrictions;
  final double dietGoal;
  final int mealsPerDay;
  final DietIntensity dietIntensity;
  final DailyBudget dailyBudget;
  final CookingSkills cookingSkills;
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
    this.dietStyle,
    required this.dietaryRestrictions,
    required this.dietGoal,
    required this.mealsPerDay,
    required this.dietIntensity,
    required this.dailyBudget,
    required this.cookingSkills,
    required this.activityLevel,
    required this.stressLevel,
    required this.sleepQuality,
    this.musclePercentage,
    this.fatPercentage,
    this.waterPercentage,
  });

  Map<String, dynamic> toJson() => {
    'gender': gender.toJson(),
    'height_cm': height,
    'weight_kg': weight,
    'date_of_birth': dateOfBirth.toIso8601String(),
    'diet_type': dietType.toJson(),
    'diet_style': dietStyle?.toJson(),
    'dietary_restrictions': dietaryRestrictions.map((a) => a.toJson()).toList(),
    'diet_goal_kg': dietGoal,
    'meals_per_day': mealsPerDay,
    'diet_intensity': dietIntensity.toJson(),
    'daily_budget': dailyBudget.toJson(),
    'cooking_skills': cookingSkills.toJson(),
    'activity_level': activityLevel.toJson(),
    'stress_level': stressLevel.toJson(),
    'sleep_quality': sleepQuality.toJson(),
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
      dietStyle: json['diet_style'] != null
          ? DietStyle.fromJson(json['diet_style'])
          : null,
      dietaryRestrictions:
          (json['dietary_restrictions'] as List<dynamic>)
              .map((e) => DietaryRestriction.fromJson(e))
              .toList(),
      dietGoal: (json['diet_goal_kg'] as num).toDouble(),
      mealsPerDay: json['meals_per_day'] as int,
      dietIntensity: DietIntensity.fromJson(json['diet_intensity']),
      dailyBudget: DailyBudget.fromJson(json['daily_budget']),
      cookingSkills: CookingSkills.fromJson(json['cooking_skills']),
      activityLevel: ActivityLevel.fromJson(json['activity_level']),
      stressLevel: StressLevel.fromJson(json['stress_level']),
      sleepQuality: SleepQuality.fromJson(json['sleep_quality']),
      musclePercentage: (json['muscle_percentage'] as num?)?.toDouble(),
      fatPercentage: (json['fat_percentage'] as num?)?.toDouble(),
      waterPercentage: (json['water_percentage'] as num?)?.toDouble(),
    );
  }
}
