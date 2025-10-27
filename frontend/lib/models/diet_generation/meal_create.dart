import 'package:frontend/models/diet_generation/meal_type.dart';

class MealCreate {
  final String mealName;
  final MealType mealType;
  final int iconId;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  MealCreate({
    required this.mealName,
    required this.mealType,
    required this.iconId,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toJson() {
    return {
      'meal_name': mealName,
      'meal_type': mealType.toJson(),
      'icon_id': iconId,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  factory MealCreate.fromJson(Map<String, dynamic> json) {
    return MealCreate(
      mealType: MealType.fromJson(json['meal_type']),
      mealName: json['meal_name'],
      iconId: json['icon_id'],
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }
}
