import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/repository/token_storage.dart';

class TokenStorageMobile implements TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  TokenStorageMobile({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
    } catch (e) {
      throw Exception('Failed to save access token');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      throw Exception('Failed to get access token');
    }
  }

  @override
  Future<void> deleteAccessToken() async {
    try {
      await _storage.delete(key: _accessTokenKey);
    } catch (e) {
      throw Exception('Failed to delete access token');
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      throw Exception('Failed to save refresh token');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      throw Exception('Failed to get refresh token');
    }
  }

  @override
  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      throw Exception('Failed to delete refresh token');
    }
  }
}
