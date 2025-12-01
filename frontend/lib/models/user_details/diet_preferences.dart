import 'package:frontend/models/user_details/diet_intensity.dart';
import 'package:frontend/models/user_details/diet_type.dart';
import 'package:frontend/models/user_details/dietary_restriction.dart';

class DietPreferences {
  final DietType dietType;
  final List<Allergies> dietaryRestriction;
  final double dietGoal;
  final int mealsPerDay;
  final DietIntensity dietIntensity;

  DietPreferences({
    required this.dietType,
    required this.dietaryRestriction,
    required this.dietGoal,
    required this.mealsPerDay,
    required this.dietIntensity,
  });

  Map<String, dynamic> toJson() => {
    'diet_type': dietType,
    'dietary_restriction': dietaryRestriction,
    'diet_goal_kg': dietGoal,
    'meals_per_day': mealsPerDay,
    'diet_intensity': dietIntensity,
  };
}
