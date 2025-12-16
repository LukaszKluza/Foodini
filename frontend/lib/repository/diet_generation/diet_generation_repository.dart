import 'package:dio/dio.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/diet_generation/composed_meal_item.dart';
import 'package:frontend/models/diet_generation/custom_meal_update_request.dart';
import 'package:frontend/models/diet_generation/daily_macros_summary_create.dart';
import 'package:frontend/models/diet_generation/daily_meals_create.dart';
import 'package:frontend/models/diet_generation/daily_summary.dart';
import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/models/diet_generation/meal_info_update_request.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/models/diet_generation/remove_meal_request.dart';
import 'package:frontend/models/diet_generation/remove_meal_response.dart';
import 'package:frontend/repository/api_client.dart';
import 'package:frontend/services/barcode_scanner_service.dart';
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

  Future<ComposedMealItem> addCustomMeal(CustomMealUpdateRequest customMealUpdateRequest, UuidValue userId) async {
    try {
      final response = await apiClient.addDailyMeal(customMealUpdateRequest, userId);
      return ComposedMealItem.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data ?? 'Error while editing daily meal', statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while editing daily meal: $e');
    } finally {
      await cacheManager.clearAllCache();
    }
  }

  Future<ComposedMealItem> updateCustomMeal(CustomMealUpdateRequest customMealUpdateRequest, UuidValue userId) async {
    try {
      final response = await apiClient.updateDailyMeal(customMealUpdateRequest, userId);
      return ComposedMealItem.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data ?? 'Error while adding daily meal', statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while adding daily meal: $e');
    } finally {
      await cacheManager.clearAllCache();
    }
  }

   Future<RemoveMealResponse> removeMealFromSummary(RemoveMealRequest removeMealRequest, UuidValue userId) async {
    try {
      final response = await apiClient.removeMealFromSummary(removeMealRequest, userId);
      return RemoveMealResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data ?? 'Error while removing meal from summary', statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while removing meal from summary: $e');
    } finally {
      await cacheManager.clearAllCache();
    }
  }

  Future<MealInfo> addScannedProduct({
    String? barcode,
    XFile? uploadedFile,
    required MealType mealType,
    required DateTime day,
    required UuidValue userId
  }) async {
    try {
      final barcodeScannerService = BarcodeScannerService();
      if (uploadedFile != null) {
        barcode = await barcodeScannerService.scanBarcodeFromGallery(uploadedFile);
      }
      final response = await apiClient.addScannedProduct(barcode: barcode, uploadedFile: uploadedFile, mealType: mealType, day: day, userId: userId);
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
