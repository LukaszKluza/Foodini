import 'allergy.dart';
import 'diet_intensity.dart';
import 'diet_type.dart';

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
