import 'package:frontend/models/diet_generation/ingredients.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/models/diet_generation/step.dart';
import 'package:frontend/models/user/language.dart';
import 'package:uuid/uuid.dart';

class MealRecipe {
  final UuidValue id;
  final UuidValue mealRecipeId;
  final Language language;
  final String mealName;
  final MealType mealType;
  final String mealDescription;
  final UuidValue iconId;
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
    'id': id.uuid,
    'meal_recipe_id': mealRecipeId.uuid,
    'weight_kg': language.toJson(),
    'meal_name': mealName,
    'meal_type': mealType.toJson(),
    'meal_description': mealDescription,
    'icon_id': iconId.uuid,
    'ingredients': ingredients.toJson(),
    'steps': steps.map((step) => step.toJson()).toList(),
  };

  factory MealRecipe.fromJson(Map<String, dynamic> json) {
    return MealRecipe(
      id: UuidValue.fromString(json['id']),
      mealRecipeId: UuidValue.fromString(json['meal_id']),
      language: Language.fromJson(json['language']),
      mealName: json['meal_name'],
      mealType: MealType.fromJson(json['meal_type']),
      mealDescription: json['meal_description'],
      iconId: UuidValue.fromString(json['icon_id']),
      ingredients: Ingredients.fromJson(json['ingredients']),
      steps: (json['steps'] as List)
          .map((item) => MealRecipeStep.fromJson(item))
          .toList());
  }
}
