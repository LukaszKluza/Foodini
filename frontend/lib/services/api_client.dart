import 'package:dio/dio.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/models/change_password_request.dart';
import 'package:frontend/models/login_request.dart';
import 'package:frontend/models/provide_email_request.dart';
import 'package:frontend/models/register_request.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/utils/global_error_interceptor.dart';

class ApiClient {
  final Dio _client;
  final TokenStorageRepository _tokenStorage;

  ApiClient([Dio? client, TokenStorageRepository? tokenStorage])
      : _client = client ?? Dio(BaseOptions(headers: {'Content-Type': 'application/json'})),
        _tokenStorage = tokenStorage ?? TokenStorageRepository() {
    _client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requiresAuth = options.extra['requiresAuth'] == true;

          if (requiresAuth) {
            final accessToken = await _tokenStorage.getAccessToken();
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
      ),
    );
    _client.interceptors.add(GlobalErrorInterceptor(this, _tokenStorage));
  }

  get dio => _client;

  Future<Response> getUser() {
    return _client.get(
      AppConfig.getUserUrl,
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> register(RegisterRequest request) {
    return _client.post(
      AppConfig.registerUrl,
      data: request.toJson(),
      options: Options(extra: {'requiresAuth': false}),
    );
  }

  Future<Response> login(LoginRequest request) {
    return _client.post(
      AppConfig.loginUrl,
      data: request.toJson(),
      options: Options(extra: {'requiresAuth': false}),
    );
  }

  Future<Response> provideEmail(ProvideEmailRequest request) {
    return _client.post(
      AppConfig.changePasswordUrl,
      data: request.toJson(),
      options: Options(extra: {'requiresAuth': false}),
    );
  }

  Future<Response> changePassword(ChangePasswordRequest request) {
    return _client.post(
      AppConfig.confirmNewPasswordUrl,
      data: request.toJson(),
      options: Options(extra: {'requiresAuth': false}),
    );
  }

  Future<Response> refreshTokens() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    return _client.post(
      AppConfig.refreshTokensUrl,
      options: Options(
        headers: {
          'Authorization': 'Bearer $refreshToken',
        },
      ),
    );
  }

  Future<Response> logout(int userId) {
    return _client.get(
      AppConfig.logoutUrl,
      queryParameters: {'user_id': userId},
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> resendVerificationMail(String email) {
    return _client.get(
      AppConfig.resendVerificationEmailUrl,
      queryParameters: {'email': email},
      options: Options(extra: {'requiresAuth': false}),
    );
  }

  Future<Response> delete(int userId) {
    return _client.delete(
      '${AppConfig.deleteUrl}/$userId',
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> refreshRequest(RequestOptions requestOptions) async {
    return _client.request(
      requestOptions.path,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        extra: {'requiresAuth': true},
      ),
    );
  }
}
