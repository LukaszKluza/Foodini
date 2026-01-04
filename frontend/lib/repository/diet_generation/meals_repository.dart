import 'package:dio/dio.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/diet_generation/meal_create.dart';
import 'package:frontend/models/diet_generation/meal_recipe.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/repository/api_client.dart';
import 'package:frontend/utils/cache_manager.dart';
import 'package:uuid/uuid.dart';

class MealsRepository {
  final ApiClient apiClient;
  final CacheManager cacheManager;

  MealsRepository(this.apiClient, this.cacheManager);

  Future<MealCreate> getMealDetails(UuidValue mealId, UuidValue userId) async {
    try {
      final response = await apiClient.getMealDetails(mealId, userId);
      return MealCreate.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while getting meal details: $e');
    }
  }

  Future<MealRecipe> getMealRecipe(UuidValue userId, UuidValue mealId, Language language) async {
    try {
      final response = await apiClient.getMealRecipe(mealId, language, userId);
      return MealRecipe.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while getting meal recipe: $e');
    }
  }
}
