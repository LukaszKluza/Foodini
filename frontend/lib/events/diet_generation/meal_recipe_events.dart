import 'package:frontend/models/user/language.dart';

abstract class MealRecipeEvent {}

class MealRecipeInit extends MealRecipeEvent {
  final int mealId;
  final Language language;

  MealRecipeInit(this.mealId, this.language);
}

