import 'package:universal_html/html.dart' as html;
import 'token_storage_repository.dart';

class TokenStorageWeb implements TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  @override
  Future<void> saveAccessToken(String token) async {
    html.window.sessionStorage[_accessTokenKey] = token;
  }

  @override
  Future<String?> getAccessToken() async {
    return html.window.sessionStorage[_accessTokenKey];
  }

  @override
  Future<void> deleteAccessToken() async {
    html.window.sessionStorage.remove(_accessTokenKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    html.window.sessionStorage[_refreshTokenKey] = token;
  }

  @override
  Future<String?> getRefreshToken() async {
    return html.window.sessionStorage[_refreshTokenKey];
  }

  @override
  Future<void> deleteRefreshToken() async {
    html.window.sessionStorage.remove(_refreshTokenKey);
  }
}
