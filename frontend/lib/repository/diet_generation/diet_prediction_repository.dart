import 'package:dio/dio.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/diet_generation/meal_recipe.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/repository/api_client.dart';
import 'package:frontend/utils/cache_manager.dart';

class DietPredictionRepository {
  final ApiClient apiClient;
  final CacheManager cacheManager;

  DietPredictionRepository(this.apiClient, this.cacheManager);

  Future<MealRecipe> getMealRecipe(int userId, int mealRecipeId, Language language) async {
    try {
      final response = await apiClient.getMealRecipe(mealRecipeId, language, userId);
      return MealRecipe.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while getting meal recipe: $e');
    }
  }

  Future<void> generateMealPlan(int userId) async {
    try {
      await apiClient.generateMealPlan(userId);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while generating meal plan: $e');
    } finally {
      await cacheManager.clearAllCache();
    }
  }
}