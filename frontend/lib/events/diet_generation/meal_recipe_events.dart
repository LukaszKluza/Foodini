import 'package:frontend/models/user/language.dart';
import 'package:uuid/uuid_value.dart';

abstract class MealRecipeEvent {}

class MealRecipeInit extends MealRecipeEvent {
  final UuidValue mealId;
  final Language language;

  MealRecipeInit(this.mealId, this.language);
}

