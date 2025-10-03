import 'package:frontend/models/diet_prediction/ingredients.dart';
import 'package:frontend/models/diet_prediction/meal_type.dart';
import 'package:frontend/models/diet_prediction/step.dart';
import 'package:frontend/models/user/language.dart';

class MealRecipe {
  final int id;
  final int mealRecipeId;
  final Language language;
  final String mealName;
  final MealType mealType;
  final String mealDescription;
  final int iconId;
  final Ingredients ingredients;
  final List<MealRecipeStep> steps;

  MealRecipe({
    required this.id,
    required this.mealRecipeId,
    required this.language,
    required this.mealName,
    required this.mealType,
    required this.mealDescription,
    required this.iconId,
    required this.ingredients,
    required this.steps,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'meal_recipe_id': mealRecipeId,
    'weight_kg': language.toJson(),
    'meal_name': mealName,
    'meal_type': mealType.toJson(),
    'meal_description': mealDescription,
    'icon_id': iconId,
    'ingredients': ingredients.toJson(),
    'steps': steps.map((step) => step.toJson()).toList(),
  };

  factory MealRecipe.fromJson(Map<String, dynamic> json) {
    return MealRecipe(
      id: json['id'] as int,
      mealRecipeId: json['meal_id'] as int,
      language: Language.fromJson(json['language']),
      mealName: json['meal_name'],
      mealType: MealType.fromJson(json['meal_type']),
      mealDescription: json['meal_description'],
      iconId: json['icon_id'] as int,
      ingredients: Ingredients.fromJson(json['ingredients']),
      steps: (json['steps'] as List)
          .map((item) => MealRecipeStep.fromJson(item))
          .toList());
  }
}
