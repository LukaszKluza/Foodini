import 'package:frontend/models/diet_generation/meal_status.dart';
import 'package:uuid/uuid_value.dart';

class MealInfo {
  final UuidValue? mealId;
  final MealStatus status;
  final String? name;
  final String? description;
  final String? iconPath;
  final int? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  MealInfo({
    this.mealId,
    required this.status,
    this.name,
    this.description,
    this.iconPath,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  factory MealInfo.fromJson(Map<String, dynamic> json) {
    return MealInfo(
      mealId: UuidValue.fromString(json['meal_id']),
      status: MealStatus.fromJson(json['status']),
      name: json['name'],
      description: json['description'],
      iconPath: json['icon_path'],
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (mealId != null) 'meal_id': mealId.toString(),
      'status': status.toJson(),
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (iconPath != null) 'icon_path': iconPath,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
    };
  }
}