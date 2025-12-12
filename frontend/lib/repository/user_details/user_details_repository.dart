import 'package:dio/dio.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/models/user_details/diet_form.dart';
import 'package:frontend/models/user_details/macros.dart';
import 'package:frontend/models/user_details/predicted_calories.dart';
import 'package:frontend/models/user_details/user_statistics.dart';
import 'package:frontend/models/user_details/user_weight_history.dart';
import 'package:frontend/repository/api_client.dart';
import 'package:frontend/utils/cache_manager.dart';
import 'package:uuid/uuid_value.dart';

class UserDetailsRepository {
  final ApiClient apiClient;
  final CacheManager? cacheManager;

  UserDetailsRepository(this.apiClient, [this.cacheManager]);

  Future<DietForm> getDietPreferences(UuidValue userId) async {
    try {
      final response = await apiClient.getDietPreferences(userId);
      return DietForm.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while getting diet form preferences: $e');
    }
  }

  Future<void> submitDietForm(DietForm request, UuidValue userId) async {
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
      UuidValue userId,
  ) async {
    try {
      final response = await apiClient.submitMacrosChange(request, userId);
      return PredictedCalories.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while submitting macros change: $e');
    }
  }

  Future<PredictedCalories> addCaloriesPrediction(UuidValue userId) async {
    try {
      final response = await apiClient.addCaloriesPrediction(userId);
      return PredictedCalories.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while adding calories prediction: $e');
    }
  }

  Future<PredictedCalories> getCaloriesPrediction(UuidValue userId) async {
    try {
      final response = await apiClient.getCaloriesPrediction(userId);
      return PredictedCalories.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while fetching calories prediction: $e');
    }
  }

  Future<UserStatistics> getUserStatistics(UuidValue userId) async {
    try {
      final response = await apiClient.getUserStatistics(userId);
      return UserStatistics.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while fetching user statistics: $e');
    }
  }

  Future<UserWeightHistory?> getUserWeightForDay(DateTime day, UuidValue userId) async {
    try {
      final response = await apiClient.getUserWeightForDay(day, userId);
      if (response.data == null) return null;
      return UserWeightHistory.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while fetching user weight for day: $e');
    }
  }

  Future<List<UserWeightHistory>> getUserWeightHistory({
    required DateTime start,
    required DateTime end,
    required UuidValue userId,
  }) async {
    try {
      final response = await apiClient.getWeightHistory(
        start: start,
        end: end,
        userId: userId,
      );

      final data = response.data as List;
      return data.map((e) => UserWeightHistory.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while fetching weight history: $e');
    }
  }

  Future<UserWeightHistory> addOrUpdateUserWeight(UserWeightHistory request, UuidValue userId) async {
    try {
      final response = await apiClient.addUserWeight(request.toJson(), userId);

      if (cacheManager != null) {
        try {
          final statsUri = Uri.parse('${Endpoints.userStatistics}?user_id=${userId.uuid}');
          final day = request.day.toIso8601String().split('T').first;
          final weightUri = Uri.parse('${Endpoints.userWeightHistory}/$day?user_id=${userId.uuid}');
          await cacheManager!.clearCacheFor(statsUri);
          await cacheManager!.clearCacheFor(weightUri);
        } catch (_) {
        }
      }

      return UserWeightHistory.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data, statusCode: e.response?.statusCode);
    } catch (e) {
      throw Exception('Error while adding/updating user weight: $e');
    }
  }
}
