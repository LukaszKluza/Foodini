import 'package:frontend/models/diet_generation/ingredients.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/models/diet_generation/step.dart';
import 'package:frontend/models/user/language.dart';
import 'package:uuid/uuid.dart';

class MealRecipe {
  final UuidValue id;
  final UuidValue mealId;
  final Language language;
  final String mealName;
  final String iconPath;
  final MealType mealType;
  final String mealDescription;
  final Ingredients ingredients;
  final List<MealRecipeStep> steps;

  MealRecipe({
    required this.id,
    required this.mealId,
    required this.language,
    required this.mealName,
    required this.iconPath,
    required this.mealType,
    required this.mealDescription,
    required this.ingredients,
    required this.steps,
  });

  Map<String, dynamic> toJson() => {
    'id': id.uuid,
    'meal_recipe_id': mealId.uuid,
    'weight_kg': language.toJson(),
    'meal_name': mealName,
    'icon_path': iconPath,
    'meal_type': mealType.toJson(),
    'meal_description': mealDescription,
    'ingredients': ingredients.toJson(),
    'steps': steps.map((step) => step.toJson()).toList(),
  };

  factory MealRecipe.fromJson(Map<String, dynamic> json) {
    return MealRecipe(
      id: UuidValue.fromString(json['id']),
      mealId: UuidValue.fromString(json['meal_id']),
      language: Language.fromJson(json['language']),
      mealName: json['meal_name'],
      iconPath: json['icon_path'],
      mealType: MealType.fromJson(json['meal_type']),
      mealDescription: json['meal_description'],
      ingredients: Ingredients.fromJson(json['ingredients']),
      steps:
          (json['steps'] as List)
              .map((item) => MealRecipeStep.fromJson(item))
              .toList(),
    );
  }
}
