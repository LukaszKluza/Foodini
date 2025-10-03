import 'package:frontend/models/diet_prediction/meal_type.dart';

class MealIconInfo {
  final int id;
  final MealType mealType;
  final String iconPath;

  MealIconInfo({
    required this.id,
    required this.mealType,
    required this.iconPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'meal_type': mealType.toJson(),
    'icon_path': iconPath,
  };

  factory MealIconInfo.fromJson(Map<String, dynamic> json) {
    return MealIconInfo(
      id: json['id'] as int,
      mealType: MealType.fromJson(json['meal_type']),
      iconPath: json['icon_path']
    );
  }
}
