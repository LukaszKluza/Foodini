import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:universal_html/html.dart' as html;

class TokenStorageRepository {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) async {
    if (kIsWeb) {
      html.window.localStorage[_accessTokenKey] = token;
    } else {
      await _storage.write(key: _accessTokenKey, value: token);
    }
  }

  Future<String?> getAccessToken() async {
    if (kIsWeb) {
      return html.window.localStorage[_accessTokenKey];
    } else {
      return await _storage.read(key: _accessTokenKey);
    }
  }

  Future<void> deleteAccessToken() async {
    if (kIsWeb) {
      html.window.localStorage.remove(_accessTokenKey);
    } else {
      await _storage.delete(key: _accessTokenKey);
    }
  }

  Future<void> saveRefreshToken(String token) async {
    if (kIsWeb) {
      html.window.localStorage[_refreshTokenKey] = token;
    } else {
      await _storage.write(key: _refreshTokenKey, value: token);
    }
  }

  Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      return html.window.localStorage[_refreshTokenKey];
    } else {
      return await _storage.read(key: _refreshTokenKey);
    }
  }

  Future<void> deleteRefreshToken() async {
    if (kIsWeb) {
      html.window.localStorage.remove(_refreshTokenKey);
    } else {
      await _storage.delete(key: _refreshTokenKey);
    }
  }
}
