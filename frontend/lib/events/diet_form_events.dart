import 'package:frontend/assets/calories_prediction_enums/activity_level.pbenum.dart';
import 'package:frontend/assets/calories_prediction_enums/sleep_quality.pbenum.dart';
import 'package:frontend/assets/calories_prediction_enums/stress_level.pbenum.dart';
import 'package:frontend/assets/diet_preferences_enums/allergy.pbenum.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_intensity.pbenum.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_type.pbenum.dart';
import 'package:frontend/assets/profile_details/gender.pbenum.dart';

abstract class DietFormEvent {}

class UpdateGender extends DietFormEvent {
  final Gender gender;
  UpdateGender(this.gender);
}

class UpdateHeight extends DietFormEvent {
  final double height;
  UpdateHeight(this.height);
}

class UpdateWeight extends DietFormEvent {
  final double weight;
  UpdateWeight(this.weight);
}

class UpdateDateOfBirth extends DietFormEvent {
  final DateTime dateOfBirth;
  UpdateDateOfBirth(this.dateOfBirth);
}

class UpdateDietType extends DietFormEvent {
  final DietType dietType;
  UpdateDietType(this.dietType);
}

class UpdateAllergies extends DietFormEvent {
  final List<Allergy> allergies;
  UpdateAllergies(this.allergies);
}

class UpdateDietGoal extends DietFormEvent {
  final double dietGoal;
  UpdateDietGoal(this.dietGoal);
}

class UpdateMealsPerDay extends DietFormEvent {
  final int mealsPerDay;
  UpdateMealsPerDay(this.mealsPerDay);
}

class UpdateDietIntensity extends DietFormEvent {
  final DietIntensity dietIntensity;
  UpdateDietIntensity(this.dietIntensity);
}

class UpdateActivityLevel extends DietFormEvent {
  final ActivityLevel activityLevel;
  UpdateActivityLevel(this.activityLevel);
}

class UpdateStressLevel extends DietFormEvent {
  final StressLevel stressLevel;
  UpdateStressLevel(this.stressLevel);
}

class UpdateSleepQuality extends DietFormEvent {
  final SleepQuality sleepQuality;
  UpdateSleepQuality(this.sleepQuality);
}

class UpdateMusclePercentage extends DietFormEvent {
  final double musclePercentage;
  UpdateMusclePercentage(this.musclePercentage);
}

class UpdateWaterPercentage extends DietFormEvent {
  final double waterPercentage;
  UpdateWaterPercentage(this.waterPercentage);
}

class UpdateFatPercentage extends DietFormEvent {
  final double fatPercentage;
  UpdateFatPercentage(this.fatPercentage);
}

class SubmitForm extends DietFormEvent {}
