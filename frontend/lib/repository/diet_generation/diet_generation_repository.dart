import 'package:dio/dio.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/diet_generation/custom_meal_update_request.dart';
import 'package:frontend/models/diet_generation/daily_macros_summary_create.dart';
import 'package:frontend/models/diet_generation/daily_meals_create.dart';
import 'package:frontend/models/diet_generation/meal_info_update_request.dart';
import 'package:frontend/repository/api_client.dart';

class DietGenerationRepository {
  final ApiClient apiClient;

  DietGenerationRepository(this.apiClient);

  Future<DailyMealsCreate> getDailySummaryMeals(DateTime day, int userId) async {
    try {
      final response = await apiClient.getDailySummaryMeals(day, userId);
      return DailyMealsCreate.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while getting daily summary meals: $e');
    }
  }

  Future<DailyMealsCreate> addDailySummaryMeals(DailyMealsCreate dailyMealsCreate, int userId) async {
    try {
      final response = await apiClient.addDailySummaryMeals(dailyMealsCreate, userId);
      return DailyMealsCreate.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while adding daily summary meals: $e');
    }
  }

  Future<DailyMealsCreate> updateDailySummaryMeals(MealInfoUpdateRequest mealInfoUpdateRequest, int userId) async {
    try {
      final response = await apiClient.updateDailySummaryMeals(mealInfoUpdateRequest, userId);
      return DailyMealsCreate.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while updating daily summary meals: $e');
    }
  }

  Future<DailyMealsCreate> addCustomMeal(CustomMealUpdateRequest customMealUpdateRequest, int userId) async {
    try {
      final response = await apiClient.addCustomMeal(customMealUpdateRequest, userId);
      return DailyMealsCreate.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while adding custom meal: $e');
    }
  }

  Future<DailyMacrosSummaryCreate> getDailySummaryMacros(DateTime day, int userId) async {
    try {
      final response = await apiClient.getDailySummaryMacros(day, userId);
      return DailyMacrosSummaryCreate.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while getting daily summary meals: $e');
    }
  }

  Future<DailyMacrosSummaryCreate> addDailySummaryMacros(DailyMealsCreate dailyMealsCreate, int userId) async {
    try {
      final response = await apiClient.addDailySummaryMacros(dailyMealsCreate, userId);
      return DailyMacrosSummaryCreate.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while adding daily summary meals: $e');
    }
  }
}
