import 'package:dio/dio.dart';
import 'package:frontend/repository/token_storage.dart';
import 'package:frontend/services/api_client.dart';

class GlobalErrorInterceptor extends Interceptor {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  GlobalErrorInterceptor(this._apiClient, this._tokenStorage);

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response != null) {
      final statusCode = err.response?.statusCode;
      String message = "Default error message.";

      switch (statusCode) {
        case 401:
          await _handleUnauthorizedError(err, handler);
          break;
        case 500:
          message = "Server error";
          break;
        default:
          message = "Error $statusCode";
      }

      _showErrorDialog(message);
      return super.onError(err, handler);
    }
    return super.onError(err, handler);
  }

  Future<void> _handleUnauthorizedError(DioException err, ErrorInterceptorHandler handler) async {
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (refreshToken != null) {
      try {
        final response = await _apiClient.refreshTokens();

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
        _showErrorDialog("Session expired.");
      }
    } else {
      _showErrorDialog("Session expired.");
    }
  }

  void _showErrorDialog(String message) {
    print(message);
  }
}
