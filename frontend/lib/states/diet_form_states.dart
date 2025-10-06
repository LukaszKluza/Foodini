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

const _noChange = Object();

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
    Object? gender = _noChange,
    Object? height = _noChange,
    Object? weight = _noChange,
    Object? dateOfBirth = _noChange,
    Object? dietType = _noChange,
    Object? allergies = _noChange,
    Object? dietGoal = _noChange,
    Object? mealsPerDay = _noChange,
    Object? dietIntensity = _noChange,
    Object? activityLevel = _noChange,
    Object? stressLevel = _noChange,
    Object? sleepQuality = _noChange,
    Object? musclePercentage = _noChange,
    Object? fatPercentage = _noChange,
    Object? waterPercentage = _noChange,
    Object? isSubmitting = _noChange,
    Object? isSuccess = _noChange,
    Object? errorMessage = _noChange,
  }) {
    return DietFormSubmit(
      gender: gender == _noChange ? this.gender : gender as Gender?,
      height: height == _noChange ? this.height : height as double?,
      weight: weight == _noChange ? this.weight : weight as double?,
      dateOfBirth:
          dateOfBirth == _noChange
              ? this.dateOfBirth
              : dateOfBirth as DateTime?,
      dietType: dietType == _noChange ? this.dietType : dietType as DietType?,
      allergies:
          allergies == _noChange ? this.allergies : allergies as List<Allergy>?,
      dietGoal: dietGoal == _noChange ? this.dietGoal : dietGoal as double?,
      mealsPerDay:
          mealsPerDay == _noChange ? this.mealsPerDay : mealsPerDay as int?,
      dietIntensity:
          dietIntensity == _noChange
              ? this.dietIntensity
              : dietIntensity as DietIntensity?,
      activityLevel:
          activityLevel == _noChange
              ? this.activityLevel
              : activityLevel as ActivityLevel?,
      stressLevel:
          stressLevel == _noChange
              ? this.stressLevel
              : stressLevel as StressLevel?,
      sleepQuality:
          sleepQuality == _noChange
              ? this.sleepQuality
              : sleepQuality as SleepQuality?,
      musclePercentage:
          musclePercentage == _noChange
              ? this.musclePercentage
              : musclePercentage as double?,
      fatPercentage:
          fatPercentage == _noChange
              ? this.fatPercentage
              : fatPercentage as double?,
      waterPercentage:
          waterPercentage == _noChange
              ? this.waterPercentage
              : waterPercentage as double?,
      isSubmitting:
          isSubmitting == _noChange ? this.isSubmitting : isSubmitting as bool,
      isSuccess: isSuccess == _noChange ? this.isSuccess : isSuccess as bool,
      errorMessage:
          errorMessage == _noChange
              ? this.errorMessage
              : errorMessage as String?,
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
  final DietFormSubmit previousData;
  final String Function(BuildContext)? getMessage;
  final ApiException? error;

  DietFormSubmitFailure({
    required this.previousData,
    this.getMessage,
    this.error,
  });
}
