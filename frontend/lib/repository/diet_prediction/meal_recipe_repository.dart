import 'package:dio/dio.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/diet_prediction/meal_recipe.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/services/api_client.dart';

class MealRecipeRepository {
  final ApiClient apiClient;

  MealRecipeRepository(this.apiClient);

  Future<MealRecipe> getMealRecipe(int userId, int mealRecipeId,Language language) async {
    try {
      final response = await apiClient.getMealRecipe(mealRecipeId, language, userId);
      return MealRecipe.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while getting meal recipe: $e');
    }
  }
}
