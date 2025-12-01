import 'package:uuid/uuid_value.dart';

class MealInfo {
  final UuidValue mealId;
  final String name;
  final String? description;
  final String? explanation;
  final String? iconPath;
  final int? calories;
  final int? weight;
  final double? protein;
  final double? carbs;
  final double? fat;

  MealInfo({
    required this.mealId,
    required this.name,
    this.description,
    this.explanation,
    this.iconPath,
    this.weight,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  factory MealInfo.fromJson(Map<String, dynamic> json) {
    return MealInfo(
      mealId: UuidValue.fromString(json['meal_id']),
      name: json['name'],
      description: json['description'],
      explanation: json['explanation'],
      iconPath: json['icon_path'],
      weight: json['weight'] as int,
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_id': mealId.toString(),
      'name': name,
      if (description != null) 'description': description,
      if (explanation != null) 'explanation': explanation,
      if (iconPath != null) 'icon_path': iconPath,
      if (weight != null) 'weight': weight,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
    };
  }
}