import 'package:dio/dio.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/models/change_password_request.dart';
import 'package:frontend/models/login_request.dart';
import 'package:frontend/models/register_request.dart';
import 'package:frontend/repository/token_storage_repository.dart';

class ApiClient {
  final Dio _client;
  final TokenStorageRepository tokenStorage = TokenStorageRepository();

  ApiClient([Dio? client])
    : _client =
          client ??
          Dio(BaseOptions(headers: {'Content-Type': 'application/json'})) {
    _client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requiresAuth = options.extra['requiresAuth'] == true;

          if (requiresAuth) {
            final accessToken = await tokenStorage.getAccessToken();
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
      ),
    );
  }

  get dio => _client;

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

  Future<Response> changePassword(ChangePasswordRequest request) {
    return _client.post(
      AppConfig.changePasswordUrl,
      data: request.toJson(),
      options: Options(extra: {'requiresAuth': false}),
    );
  }

  Future<Response> refreshTokens() {
    return _client.post(
      AppConfig.refreshAccessTokenUrl,
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> logout() {
    int userId = 2; //TODO
    return _client.get(
      '${AppConfig.logoutUrl}?user_id=$userId',
      options: Options(extra: {'requiresAuth': true}),
    );
  }

  Future<Response> refreshRequest(RequestOptions requestOptions) async {
    return _client.request(
      requestOptions.path,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        extra: {'requiresAuth': true},
      ),
    );
  }
}
