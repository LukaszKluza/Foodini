import 'package:frontend/assets/calories_prediction_enums/activity_level.pbenum.dart';
import 'package:frontend/assets/calories_prediction_enums/sleep_quality.pbenum.dart';
import 'package:frontend/assets/calories_prediction_enums/stress_level.pbenum.dart';
import 'package:frontend/assets/diet_preferences_enums/allergy.pbenum.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_intensity.pbenum.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_type.pbenum.dart';
import 'package:frontend/assets/profile_details/gender.pbenum.dart';

class DietFormState {
  final Gender? gender;
  final double? height;
  final double? weight;
  final DateTime? dateOfBirth;

  final DietType? dietType;
  final List<Allergy>? allergies;
  final double? dietGoal;
  final int? mealsPerDay;
  final DietIntensity? dietIntensity;

  final ActivityLevel? activityLevel;
  final StressLevel? stressLevel;
  final SleepQuality? sleepQuality;
  final double? musclePercentage;
  final double? fatPercentage;
  final double? waterPercentage;

  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  DietFormState({
    this.gender,
    this.height,
    this.weight,
    this.dateOfBirth,
    this.dietType,
    this.allergies,
    this.dietGoal,
    this.mealsPerDay,
    this.dietIntensity,
    this.activityLevel,
    this.stressLevel,
    this.sleepQuality,
    this.musclePercentage,
    this.fatPercentage,
    this.waterPercentage,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  DietFormState copyWith({
    Gender? gender,
    double? height,
    double? weight,
    DateTime? dateOfBirth,
    DietType? dietType,
    List<Allergy>? allergies,
    double? dietGoal,
    int? mealsPerDay,
    DietIntensity? dietIntensity,
    ActivityLevel? activityLevel,
    StressLevel? stressLevel,
    SleepQuality? sleepQuality,
    double? musclePercentage,
    double? fatPercentage,
    double? waterPercentage,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return DietFormState(
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      dietType: dietType ?? this.dietType,
      allergies: allergies ?? this.allergies,
      dietGoal: dietGoal ?? this.dietGoal,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      dietIntensity: dietIntensity ?? this.dietIntensity,
      activityLevel: activityLevel ?? this.activityLevel,
      stressLevel: stressLevel ?? this.stressLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      musclePercentage: musclePercentage ?? this.musclePercentage,
      fatPercentage: fatPercentage ?? this.fatPercentage,
      waterPercentage: waterPercentage ?? this.waterPercentage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}
