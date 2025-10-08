import 'package:dio/dio.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/user_details/diet_form.dart';
import 'package:frontend/models/user_details/macros.dart';
import 'package:frontend/models/user_details/predicted_calories.dart';
import 'package:frontend/services/api_client.dart';

class UserDetailsRepository {
  final ApiClient apiClient;

  UserDetailsRepository(this.apiClient);

  Future<DietForm> getDietPreferences(int userId) async {
    try {
      final response = await apiClient.getDietPreferences(userId);
      return DietForm.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while getting diet form preferences: $e');
    }
  }

  Future<void> submitDietForm(DietForm request, int userId) async {
    try {
      await apiClient.submitDietForm(request, userId);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while submitting diet form: $e');
    }
  }

  Future<PredictedCalories> submitMacrosChange(
    Macros request,
    int userId,
  ) async {
    try {
      final response = await apiClient.submitMacrosChange(request, userId);
      final _ = await apiClient.generateMealPlan(userId);
      return PredictedCalories.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while submitting macros change: $e');
    }
  }

  Future<PredictedCalories> addCaloriesPrediction(int userId) async {
    try {
      final response = await apiClient.addCaloriesPrediction(userId);
      return PredictedCalories.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while adding calories prediction: $e');
    }
  }

  Future<PredictedCalories> getCaloriesPrediction(int userId) async {
    try {
      final response = await apiClient.getCaloriesPrediction(userId);
      return PredictedCalories.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while fetching calories prediction: $e');
    }
  }
}
