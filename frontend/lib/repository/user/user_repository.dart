import 'package:dio/dio.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/user/change_language_request.dart';
import 'package:frontend/models/user/change_password_request.dart';
import 'package:frontend/models/user/default_response.dart';
import 'package:frontend/models/user/logged_user.dart';
import 'package:frontend/models/user/login_request.dart';
import 'package:frontend/models/user/provide_email_request.dart';
import 'package:frontend/models/user/refreshed_tokens_response.dart';
import 'package:frontend/models/user/register_request.dart';
import 'package:frontend/models/user/user_response.dart';
import 'package:frontend/services/api_client.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository(this.apiClient);

  Future<UserResponse> getUser(int userId) async {
    try {
      final response = await apiClient.getUser(userId);
      return UserResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while getting user $e.');
    }
  }

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

  Future<void> logout(int userId) async {
    try {
      await apiClient.logout(userId);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while logging out $e.');
    }
  }

  Future<void> resendVerificationMail(String email) async {
    try {
      await apiClient.resendVerificationMail(email);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while resending verification mail $e.');
    }
  }

  Future<void> delete(int userId) async {
    try {
      await apiClient.delete(userId);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while deleting account $e.');
    }
  }

  Future<DefaultResponse?> register(RegisterRequest request) async {
    try {
      final response = await apiClient.register(request);
      return DefaultResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while registration new user $e.');
    }
  }

  Future<DefaultResponse> provideEmail(ProvideEmailRequest request) async {
    try {
      final response = await apiClient.provideEmail(request);
      return DefaultResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while sending email: $e');
    }
  }

  Future<DefaultResponse> changePassword(ChangePasswordRequest request) async {
    try {
      final response = await apiClient.changePassword(request);
      return DefaultResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while changing password: $e');
    }
  }

  Future<DefaultResponse> changeLanguage(
    ChangeLanguageRequest request,
    int userId,
  ) async {
    try {
      final response = await apiClient.changeLanguage(request, userId);
      return DefaultResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while updating language: $e');
    }
  }

  Future<RefreshedTokensResponse> refreshTokens() async {
    try {
      final response = await apiClient.refreshTokens();
      return RefreshedTokensResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.response?.data);
    } catch (e) {
      throw Exception('Error while refreshing access token: $e');
    }
  }
}
