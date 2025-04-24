import 'package:dio/dio.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/change_password_request.dart';
import 'package:frontend/models/login_request.dart';
import 'package:frontend/models/logged_user.dart';
import 'package:frontend/models/register_request.dart';
import 'package:frontend/models/user_response.dart';
import 'package:frontend/services/api_client.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  Future<LoggedUser> login(LoginRequest request) async {
    try {
      final response = await apiClient.login(request);
      return LoggedUser.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while logging $e.');
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.logout();
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while logging out $e.');
    }
  }

  Future<UserResponse> register(RegisterRequest request) async {
    try {
      final response = await apiClient.register(request);
      return UserResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while registration new user $e.');
    }
  }

  Future<UserResponse> changePassword(ChangePasswordRequest request) async {
    try {
      final response = await apiClient.changePassword(request);
      return UserResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while channing password: $e');
    }
  }

  Future<String> refreshAccessToken() async {
    try {
      final response = await apiClient.refreshAccessToken();
      return response.data['refreshed_access_token'];
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while refreshing access token: $e');
    }
  }
}
