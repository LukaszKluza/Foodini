import 'package:dio/dio.dart';
import 'package:frontend/app_router.dart';
import 'package:frontend/repository/api_client.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/utils/logger.dart';

class GlobalErrorInterceptor extends Interceptor {
  final ApiClient _apiClient;
  final TokenStorageService _tokenStorage;

  GlobalErrorInterceptor(this._apiClient, this._tokenStorage);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response != null) {
      final statusCode = err.response?.statusCode;
      String message = 'Default error message.';

      switch (statusCode) {
        case 400:
          message = 'Error $statusCode: Bad request';
          break;
        case 401:
          return await _handleUnauthorizedError(err, handler);
        case 403:
          if (err.response?.data['detail'] == 'Revoked token') {
            await _handleForbiddenError(err, handler);
          }
          message = 'Error $statusCode: Forbidden';
          break;
        case 404:
          return handler.reject(err);
        case 422:
          message = 'Error $statusCode: Unprocessable entity';
          break;
        case 500:
          message = 'Error $statusCode: Server error';
          break;
        case 502:
          message = 'Error $statusCode: Bad gateway';
          break;
        case 503:
          message = 'Error $statusCode: Service unavailable';
          break;
        case 504:
          message = 'Error $statusCode: Gateway timeout';
          break;
        default:
          message = 'Error $statusCode';
      }

      _showErrorDialog(message);
    }
    return handler.reject(err);
  }

  Future<void> _handleUnauthorizedError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    final userId = UserStorage().getUserId;

    if (refreshToken != null && userId != null) {
      try {
        final response = await _apiClient.refreshTokens(userId);

        if (response.statusCode == 200) {
          final newAccessToken = response.data['access_token'];
          final newRefreshToken = response.data['refresh_token'];
          await _tokenStorage.saveAccessToken(newAccessToken);
          await _tokenStorage.saveRefreshToken(newRefreshToken);

          final requestOptions = err.response?.requestOptions;
          if (requestOptions != null) {
            final newRequest = await _apiClient.refreshRequest(requestOptions);

            return handler.resolve(newRequest);
          }
        } else {
          _showErrorDialog('Session expired.');
          return handler.reject(err);
        }
      } catch (e) {
        _showErrorDialog('Session expired.');
        return handler.reject(err);
      }
    } else {
      _showErrorDialog('Session expired.');
      return handler.reject(err);
    }
  }

  Future<void> _handleForbiddenError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    UserStorage().removeUser();
    await TokenStorageService().deleteAccessToken();
    await TokenStorageService().deleteRefreshToken();

    router.go('/');
  }

  void _showErrorDialog(String message) {
    logger.w(message);
  }
}
