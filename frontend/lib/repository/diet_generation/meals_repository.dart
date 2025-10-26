import 'package:dio/dio.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/diet_generation/meal_create.dart';
import 'package:frontend/models/diet_generation/meal_icon_info.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/repository/api_client.dart';

class MealsRepository {
  final ApiClient apiClient;

  MealsRepository(this.apiClient);

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
}
