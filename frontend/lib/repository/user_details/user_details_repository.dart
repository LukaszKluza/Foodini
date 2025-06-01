import 'package:dio/dio.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/user_details/diet_form.dart';
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
}