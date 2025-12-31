import 'package:uuid/uuid_value.dart';

class MealInfo {
  final UuidValue mealId;
  final String name;
  final String? description;
  final String? explanation;
  final String? iconPath;
  final int calories;
  final int unitWeight;
  final double protein;
  final double carbs;
  final double fat;
  final int plannedCalories;
  final int plannedWeight;
  final double plannedProtein;
  final double plannedCarbs;
  final double plannedFat;

  MealInfo({
    required this.mealId,
    required this.name,
    this.description,
    this.explanation,
    this.iconPath,
    required this.unitWeight,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.plannedCalories,
    required this.plannedWeight,
    required this.plannedProtein,
    required this.plannedCarbs,
    required this.plannedFat,
  });

  factory MealInfo.fromJson(Map<String, dynamic> json) {
    return MealInfo(
      mealId: UuidValue.fromString(json['meal_id']),
      name: json['name'],
      description: json['description'],
      explanation: json['explanation'],
      iconPath: json['icon_path'],
      unitWeight: json['unit_weight'] as int,
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      plannedCalories: json['planned_calories'] as int,
      plannedWeight: json['planned_weight'] as int,
      plannedProtein: (json['planned_protein'] as num).toDouble(),
      plannedCarbs: (json['planned_carbs'] as num).toDouble(),
      plannedFat: (json['planned_fat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_id': mealId.toString(),
      'name': name,
      if (description != null) 'description': description,
      if (explanation != null) 'explanation': explanation,
      if (iconPath != null) 'icon_path': iconPath,
      'unit_weight': unitWeight,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'planned_calories': plannedCalories,
      'planned_weight': plannedWeight,
      'planned_protein': plannedProtein,
      'planned_carbs': plannedCarbs,
      'planned_fat': plannedFat,
    };
  }
}