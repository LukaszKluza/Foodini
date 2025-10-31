import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/diet_generation/meal_recipe_events.dart';
import 'package:frontend/models/processing_status.dart';
import 'package:frontend/repository/diet_prediction/meal_recipe_repository.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/states/diet_generation/meal_recipe.dart';
import 'package:frontend/utils/exception_converter.dart';

class MealRecipeBloc extends Bloc<MealRecipeEvent, MealRecipeState> {
  final MealRecipeRepository mealRecipeRepository;

  MealRecipeBloc(this.mealRecipeRepository) : super(MealRecipeState()) {
    on<MealRecipeInit>(_onDietPredictionInit);
  }

  Future<void> _onDietPredictionInit(
    MealRecipeInit event,
    Emitter<MealRecipeState> emit,
  ) async {
    try {
      emit(
        MealRecipeState(
          mealId: event.mealId,
          language: event.language,
          processingStatus: ProcessingStatus.gettingOnGoing,
        ),
      );

      final userId = UserStorage().getUserId!;

      final mealRecipe = await mealRecipeRepository.getMealRecipe(
        userId,
        event.mealId,
        event.language,
      );

      emit(
        state.copyWith(
          mealRecipe: mealRecipe,
          iconUrl: mealRecipe.iconPath,
          processingStatus: ProcessingStatus.gettingSuccess,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
            getErrorMessage:
                (context) =>
                ExceptionConverter.formatErrorMessage(error.data, context),
            errorCode: error.statusCode,
            processingStatus: ProcessingStatus.gettingFailure
        ),
      );
    }
  }
}
