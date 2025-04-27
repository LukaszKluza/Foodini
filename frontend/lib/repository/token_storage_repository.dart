import 'package:flutter/foundation.dart' show kIsWeb;
import 'token_storage.dart';
import 'token_storage_mobile.dart';
import 'token_storage_web.dart';

class TokenStorageRepository {
  late final TokenStorage _storage;

  TokenStorageRepository() {
    if (kIsWeb) {
      _storage = TokenStorageWeb();
    } else {
      _storage = TokenStorageMobile();
    }
  }

  Future<void> saveAccessToken(String token) => _storage.saveAccessToken(token);
  Future<String?> getAccessToken() => _storage.getAccessToken();
  Future<void> deleteAccessToken() => _storage.deleteAccessToken();

  Future<void> saveRefreshToken(String token) => _storage.saveRefreshToken(token);
  Future<String?> getRefreshToken() => _storage.getRefreshToken();
  Future<void> deleteRefreshToken() => _storage.deleteRefreshToken();
}
