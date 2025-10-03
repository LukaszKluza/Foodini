import 'package:flutter/cupertino.dart';
import 'package:frontend/models/diet_prediction/meal_recipe.dart';
import 'package:frontend/models/processing_status.dart';
import 'package:frontend/models/user/language.dart';

class MealRecipeState {
  final int? mealId;
  final Language? language;
  final MealRecipe? mealRecipe;
  final int? errorCode;
  final String Function(BuildContext)? getMessage;
  final String? iconUrl;
  final ProcessingStatus? processingStatus;

  const MealRecipeState({
    this.mealId,
    this.language,
    this.mealRecipe,
    this.errorCode,
    this.getMessage,
    this.iconUrl,
    this.processingStatus = ProcessingStatus.emptyProcessingStatus,
  });

  MealRecipeState copyWith({
    int? mealId,
    Language? language,
    MealRecipe? mealRecipe,
    int? errorCode,
    String Function(BuildContext)? getMessage,
    String? iconUrl,
    ProcessingStatus? processingStatus,
  }) {
    return MealRecipeState(
      mealId: mealId ?? this.mealId,
      language: language ?? this.language,
      mealRecipe: mealRecipe ?? this.mealRecipe,
      errorCode: errorCode ?? this.errorCode,
      getMessage: getMessage ?? this.getMessage,
      iconUrl: iconUrl ?? this.iconUrl,
      processingStatus: processingStatus ?? this.processingStatus,
    );
  }
}
