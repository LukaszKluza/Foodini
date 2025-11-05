import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:uuid/uuid_value.dart';

class MealCreate {
  final MealType mealType;
  final UuidValue iconId;
  final int calories;
  final double protein;
  final double fat;
  final double carbs;

  MealCreate({
    required this.mealType,
    required this.iconId,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  Map<String, dynamic> toJson() {
    return {
      'meal_type': mealType.toJson(),
      'icon_id': iconId,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
    };
  }

  factory MealCreate.fromJson(Map<String, dynamic> json) {
    return MealCreate(
      mealType: MealType.fromJson(json['meal_type']),
      iconId:  UuidValue.fromString(json['icon_id']),
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
    );
  }
}
