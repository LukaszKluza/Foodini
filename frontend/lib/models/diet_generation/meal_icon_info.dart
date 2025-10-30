import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:uuid/uuid_value.dart';

class MealIconInfo {
  final UuidValue id;
  final MealType mealType;
  final String iconPath;

  MealIconInfo({
    required this.id,
    required this.mealType,
    required this.iconPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id.uuid,
    'meal_type': mealType.toJson(),
    'icon_path': iconPath,
  };

  factory MealIconInfo.fromJson(Map<String, dynamic> json) {
    return MealIconInfo(
      id: UuidValue.fromString(json['id']),
      mealType: MealType.fromJson(json['meal_type']),
      iconPath: json['icon_path'],
    );
  }
}
