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
import 'package:frontend/states/diet_form_states.dart';

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

class UpdateDietStyle extends DietFormEvent {
  final DietStyle? dietStyle;

  UpdateDietStyle(this.dietStyle);
}

class UpdateAllergies extends DietFormEvent {
  final List<Allergies> allergies;

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

class UpdateDailyBudget extends DietFormEvent {
  final DailyBudget dailyBudget;

  UpdateDailyBudget(this.dailyBudget);
}

class UpdateCookingSkills extends DietFormEvent {
  final CookingSkills cookingSkills;

  UpdateCookingSkills(this.cookingSkills);
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

class UpdateAdvancedParameters extends DietFormEvent {
  final double? musclePercentage;
  final double? fatPercentage;
  final double? waterPercentage;

  UpdateAdvancedParameters({
    this.musclePercentage,
    this.fatPercentage,
    this.waterPercentage,
  });
}

class RestoreDietFormStateAfterFailure extends DietFormEvent {
  final DietFormSubmit previousData;

  RestoreDietFormStateAfterFailure(this.previousData);
}

class InitForm extends DietFormEvent {}

class SubmitForm extends DietFormEvent {}

class DietFormResetRequested extends DietFormEvent {}
