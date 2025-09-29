import 'package:frontend/models/diet_prediction/Unit.dart';

class Ingredient {
  final double volume;
  final Unit unit;
  final String name;

  Ingredient({
    required this.volume,
    required this.unit,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'volume': volume,
    'unit': unit.toJson(),
    'name': name,
  };

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      volume: json['volume'] as double,
      unit: Unit.fromJson(json['unit']),
        name: json['name'],
    );
  }
}