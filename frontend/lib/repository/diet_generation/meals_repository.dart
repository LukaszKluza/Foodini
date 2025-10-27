import 'package:dio/dio.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/diet_generation/custom_meal_update_request.dart';
import 'package:frontend/models/diet_generation/daily_meals_create.dart';
import 'package:frontend/models/diet_generation/meal_create.dart';
import 'package:frontend/models/diet_generation/meal_icon_info.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/repository/api_client.dart';
import 'package:frontend/utils/cache_manager.dart';

class MealsRepository {
  final ApiClient apiClient;
  final CacheManager cacheManager;

  MealsRepository(this.apiClient, this.cacheManager);

  Future<MealCreate> getMealDetails(int mealId, int userId) async {
    try {
      final response = await apiClient.getMealDetails(mealId, userId);
      return MealCreate.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while getting meal details: $e');
    }
  }

  Future<MealIconInfo> getMealIconInfo(int userId, MealType mealType) async {
    try {
      final response = await apiClient.getMealIconInfo(mealType, userId);
      return MealIconInfo.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while getting meal icon info: $e');
    }
  }

  Future<DailyMealsCreate> addMealDetails(CustomMealUpdateRequest customMealUpdateRequest, int userId) async {
    try {
      final response = await apiClient.addMealDetails(customMealUpdateRequest, userId);
      return DailyMealsCreate.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while adding meal details: $e');
    } finally {
      await cacheManager.clearAllCache();
    }
  }

  Future<DailyMealsCreate> updateMealDetails(CustomMealUpdateRequest customMealUpdateRequest, int userId) async {
    try {
      final response = await apiClient.updateMealDetails(customMealUpdateRequest, userId);
      return DailyMealsCreate.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while updating meal details: $e');
    } finally {
      await cacheManager.clearAllCache();
    }
  }
}
