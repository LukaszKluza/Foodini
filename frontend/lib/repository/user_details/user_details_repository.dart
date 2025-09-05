import 'package:dio/dio.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/user_details/diet_form.dart';
import 'package:frontend/models/user_details/predicted_calories.dart';
import 'package:frontend/models/user_details/predicted_macros.dart';
import 'package:frontend/services/api_client.dart';

class UserDetailsRepository {
  final ApiClient apiClient;

  UserDetailsRepository(this.apiClient);

  Future<void> submitDietForm(DietForm request, int userId) async {
    try {
      await apiClient.submitDietForm(request, userId);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while submitting diet form: $e');
    }
  }

  Future<void> submitMacrosChange(PredictedMacros request, int userId) async {
    try {
      await apiClient.submitMacrosChange(request, userId);
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
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while fetching calories prediction: $e');
    }
  }
}
