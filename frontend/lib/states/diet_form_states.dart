import 'package:flutter/material.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/models/user_details/activity_level.dart';
import 'package:frontend/models/user_details/allergy.dart';
import 'package:frontend/models/user_details/diet_form.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_type.dart';
import 'package:frontend/models/user_details/gender.dart';
import 'package:frontend/models/user_details/sleep_quality.dart';
import 'package:frontend/models/user_details/stress_level.dart';

abstract class DietFormState {}

class DietFormInit extends DietFormState {}

class DietFormSubmit extends DietFormState {
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

  DietFormSubmit({
    this.gender,
    this.height = 175.0,
    this.weight = 65.0,
    this.dateOfBirth,
    this.dietType,
    this.allergies = const [],
    this.dietGoal,
    this.mealsPerDay = 3,
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
    return DietFormSubmit(
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

  static DietFormSubmit fromDietForm(DietForm form) {
    return DietFormSubmit(
      gender: form.gender,
      height: form.height,
      weight: form.weight,
      dateOfBirth: form.dateOfBirth,
      dietType: form.dietType,
      allergies: form.allergies,
      dietGoal: form.dietGoal,
      mealsPerDay: form.mealsPerDay,
      dietIntensity: form.dietIntensity,
      activityLevel: form.activityLevel,
      stressLevel: form.stressLevel,
      sleepQuality: form.sleepQuality,
      musclePercentage: form.musclePercentage,
      fatPercentage: form.fatPercentage,
      waterPercentage: form.waterPercentage,
      isSubmitting: false,
      isSuccess: false,
      errorMessage: null,
    );
  }

  factory DietFormSubmit.initial() {
    return DietFormSubmit(
      gender: null,
      height: Constants.defaultHeight,
      weight: Constants.defaultWeight,
      dateOfBirth: null,
      dietType: null,
      allergies: const [],
      dietGoal: null,
      mealsPerDay: 3,
      dietIntensity: null,
      activityLevel: null,
      stressLevel: null,
      sleepQuality: null,
      musclePercentage: null,
      fatPercentage: null,
      waterPercentage: null,
      isSubmitting: false,
      isSuccess: false,
      errorMessage: null,
    );
  }
}

class DietFormSubmitSuccess extends DietFormState {}

class DietFormSubmitFailure extends DietFormState {
  final String Function(BuildContext)? getMessage;
  final ApiException? error;

  DietFormSubmitFailure({this.getMessage, this.error});
}
