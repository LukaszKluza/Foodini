import 'package:universal_html/html.dart' as html;
import 'token_storage.dart';

class TokenStorageWeb implements TokenStorage {
  static const _accessTokenKey = 'access_token';

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
    throw UnsupportedError('Refresh token should be stored as HttpOnly cookie.');
  }

  @override
  Future<String?> getRefreshToken() async {
    throw UnsupportedError('Refresh token should be stored as HttpOnly cookie.');
  }

  @override
  Future<void> deleteRefreshToken() async {
    throw UnsupportedError('Refresh token should be managed via HttpOnly cookie on server.');
  }
}
