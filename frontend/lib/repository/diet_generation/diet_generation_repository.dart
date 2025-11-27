import 'package:dio/dio.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/diet_generation/custom_meal_update_request.dart';
import 'package:frontend/models/diet_generation/daily_macros_summary_create.dart';
import 'package:frontend/models/diet_generation/daily_meals_create.dart';
import 'package:frontend/models/diet_generation/daily_summary.dart';
import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/models/diet_generation/meal_info_update_request.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/repository/api_client.dart';
import 'package:frontend/utils/cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid_value.dart';

class DietGenerationRepository {
  final ApiClient apiClient;
  final CacheManager cacheManager;

  DietGenerationRepository(this.apiClient, this.cacheManager);

  Future<DailySummary> getDailySummary(DateTime day, UuidValue userId) async {
    try {
      final response = await apiClient.getDailySummary(day, userId);
      return DailySummary.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while getting daily summary: $e');
    }
  }

  Future<DailyMealsCreate> getDailySummaryMeals(DateTime day, UuidValue userId) async {
    try {
      final response = await apiClient.getDailySummaryMeals(day, userId);
      return DailyMealsCreate.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while getting daily summary meals: $e');
    }
  }

  Future<void> updateDailySummaryMeals(MealInfoUpdateRequest mealInfoUpdateRequest, UuidValue userId) async {
    try {
      await apiClient.updateDailySummaryMeals(mealInfoUpdateRequest, userId);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while updating daily summary meals: $e');
    } finally {
      await cacheManager.clearAllCache();
    }
  }

  Future<MealInfo> addCustomMeal(CustomMealUpdateRequest customMealUpdateRequest, UuidValue userId) async {
    try {
      final response = await apiClient.addCustomMeal(customMealUpdateRequest, userId);
      return MealInfo.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data ?? 'Error while editing meals', statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while editing meals: $e');
    } finally {
      await cacheManager.clearAllCache();
    }
  }

  Future<MealInfo> addScannedProduct({
    String? barcode,
    XFile? uploadedFile,
    required MealType mealType,
    required UuidValue userId
  }) async {
    try {
      final response = await apiClient.addScannedProduct(barcode: barcode, uploadedFile: uploadedFile, mealType: mealType, userId: userId);
      return MealInfo.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data ?? 'Error while adding scanned product:', statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while adding scanned product: $e');
    } finally {
      await cacheManager.clearAllCache();
    }
  }

  Future<DailyMacrosSummaryCreate> getDailySummaryMacros(DateTime day, UuidValue userId) async {
    try {
      final response = await apiClient.getDailySummaryMacros(day, userId);
      return DailyMacrosSummaryCreate.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while getting daily summary macros: $e');
    }
  }

  Future<void> generateMealPlan(UuidValue userId, DateTime day) async {
    try {
      await apiClient.generateMealPlan(userId, day);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while generating meal plan: $e');
    } finally {
      await cacheManager.clearAllCache();
    }
  }
}
