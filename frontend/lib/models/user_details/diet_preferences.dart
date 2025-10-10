import 'package:frontend/models/user_details/allergy.dart';
import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_type.dart';

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
    'diet_type': dietType,
    'allergies': allergies,
    'diet_goal_kg': dietGoal,
    'meals_per_day': mealsPerDay,
    'diet_intensity': dietIntensity,
  };
}
