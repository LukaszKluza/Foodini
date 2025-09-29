import 'package:frontend/models/diet_prediction/ingredient.dart';

class Ingredients {
  final List<Ingredient> ingredients;
  final String? foodAdditives;

  Ingredients({
    required this.ingredients,
    this.foodAdditives,
  });

  Map<String, dynamic> toJson() => {
    'ingredients': ingredients.map((e) => e.toJson()).toList(),
    'food_additives': foodAdditives,
  };

  factory Ingredients.fromJson(Map<String, dynamic> json) {
    return Ingredients(
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      foodAdditives: json['food_additives'] as String?,
    );
  }
}
