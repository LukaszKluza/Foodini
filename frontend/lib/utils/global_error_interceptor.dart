import 'package:dio/dio.dart';
import 'package:frontend/api_exception.dart';
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
    if (err.response == null) {
      return _rejectAsApiException(
        handler,
        err,
        ApiException(
          'Unable to reach server',
          statusCode: null,
        ),
      );
    }

    final statusCode = err.response?.statusCode;

    switch (statusCode) {
      case 400:
        return _rejectAsApiException(
          handler,
          err,
          ApiException(
            err.response?.data ?? 'Bad request',
            statusCode: 400,
          ),
        );

      case 401:
        return await _handleUnauthorizedError(err, handler);

      case 403:
        if (err.response?.data['detail'] == 'Revoked token') {
          return await _handleForbiddenError(err, handler);
        }
        return _rejectAsApiException(
          handler,
          err,
          ApiException('Forbidden', statusCode: 403),
        );

      case 404:
        return _rejectAsApiException(
          handler,
          err,
          ApiException('Not found', statusCode: 404),
        );

      case 422:
        return _rejectAsApiException(
          handler,
          err,
          ApiException(err.response?.data, statusCode: 422),
        );

      case 500:
      case 502:
      case 503:
      case 504:
        logger.e('Server error: $statusCode');
        return _rejectAsApiException(
          handler,
          err,
          ApiException(
            'Internal server error',
            statusCode: statusCode,
          ),
        );

      default:
        return _rejectAsApiException(
          handler,
          err,
          ApiException(
            err.response?.data ?? 'Unknown error',
            statusCode: statusCode,
          ),
        );
    }
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
            final newRequest =
                await _apiClient.refreshRequest(requestOptions);
            return handler.resolve(newRequest);
          }
        }

        return _rejectAsApiException(
          handler,
          err,
          ApiException('Session expired.', statusCode: 401),
        );
      } catch (e) {
        return _rejectAsApiException(
          handler,
          err,
          ApiException('Session expired.', statusCode: 401),
        );
      }
    } else {
      return _rejectAsApiException(
        handler,
        err,
        ApiException('Session expired.', statusCode: 401),
      );
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
    return _rejectAsApiException(
      handler,
      err,
      ApiException('Forbidden', statusCode: 403),
    );
  }

  Future<void> _rejectAsApiException(
    ErrorInterceptorHandler handler,
    DioException originalErr,
    ApiException apiException,
  ) async {
    logger.w(apiException.toString());

    final wrappedErr = DioException(
      requestOptions: originalErr.requestOptions,
      error: apiException,
      response: originalErr.response,
      type: originalErr.type,
    );

    handler.reject(wrappedErr);
  }
}
