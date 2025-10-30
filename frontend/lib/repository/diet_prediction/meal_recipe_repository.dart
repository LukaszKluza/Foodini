import 'package:dio/dio.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/diet_generation/meal_icon_info.dart';
import 'package:frontend/models/diet_generation/meal_recipe.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/repository/api_client.dart';
import 'package:uuid/uuid_value.dart';

class MealRecipeRepository {
  final ApiClient apiClient;

  MealRecipeRepository(this.apiClient);

  Future<MealRecipe> getMealRecipe(UuidValue userId, UuidValue mealld, Language language) async {
    try {
      final response = await apiClient.getMealRecipe(mealld, language, userId);
      return MealRecipe.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while getting meal recipe: $e');
    }
  }

  Future<MealIconInfo> getMealIconInfo(UuidValue userId, MealType mealType) async {
    try {
      final response = await apiClient.getMealIconInfo(mealType, userId);
      return MealIconInfo.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while getting meal icon info: $e');
    }
  }
}
