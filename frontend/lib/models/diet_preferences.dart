import 'package:frontend/assets/diet_preferences_enums/allergy.pbenum.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_intensity.pb.dart';
import 'package:frontend/assets/diet_preferences_enums/diet_type.pbenum.dart';

class DietPreferences {
  final DietType dietType;
  final List<Allergy> allergies;
  final double dietGoal;
  final int mealsPerDay;
  final DietIntensity dietIntensity;

  DietPreferences({
    required this.dietType,
    required this.allergies,
    required this.dietGoal,
    required this.mealsPerDay,
    required this.dietIntensity,
  });

  Map<String, dynamic> toJson() => {
    "diet_type": dietType,
    "allergies": allergies,
    "diet_goal": dietGoal,
    "meals_per_day": mealsPerDay,
    "diet_intensity": dietIntensity,
  };
}
