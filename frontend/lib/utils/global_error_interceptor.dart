import 'package:dio/dio.dart';
import 'package:frontend/app_router.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/utils/logger.dart';

class GlobalErrorInterceptor extends Interceptor {
  final ApiClient _apiClient;
  final TokenStorageRepository _tokenStorage;

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
        case 401:
          return await _handleUnauthorizedError(err, handler);
        case 403:
          if (err.response?.data['detail'] == 'Revoked token') {
            await _handleForbiddenError(err, handler);
          }
          message = 'Error $statusCode: Forbidden';
          _showErrorDialog(message);
          break;
        case 422:
          message = 'Error $statusCode: Unprocessable entity';
        case 500:
          message = 'Error $statusCode: Server error';
        case 502:
          message = 'Error $statusCode: Bad gateway';
        case 503:
          message = 'Error $statusCode: Service unavailable';
        case 504:
          message = 'Error $statusCode: Gateway timeout';
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

    if (refreshToken != null && userId!= null) {
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
          throw DioException(
            requestOptions: err.requestOptions,
            response: Response(requestOptions: err.requestOptions),
          );
        }
      } catch (e) {
        _showErrorDialog('Session expired.');
      }
    } else {
      _showErrorDialog('Session expired.');
    }
  }

  Future<void> _handleForbiddenError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    UserStorage().removeUser();
    await TokenStorageRepository().deleteAccessToken();
    await TokenStorageRepository().deleteRefreshToken();

    router.go('/');
  }

  void _showErrorDialog(String message) {
    logger.w(message);
  }
}
