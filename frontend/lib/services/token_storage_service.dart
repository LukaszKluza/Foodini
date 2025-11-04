import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:frontend/repository/user/token_storage_mobile_repository.dart';
import 'package:frontend/repository/user/token_storage_repository.dart';
import 'package:frontend/repository/user/token_storage_web_repository.dart';

class TokenStorageService {
  static final TokenStorageService _instance =
      TokenStorageService._internal();

  late final TokenStorage _storage;

  factory TokenStorageService() => _instance;

  TokenStorageService._internal() {
    if (kIsWeb) {
      _storage = TokenStorageWeb();
    } else {
      _storage = TokenStorageMobile();
    }
  }

  Future<void> saveAccessToken(String token) => _storage.saveAccessToken(token);
  Future<String?> getAccessToken() => _storage.getAccessToken();
  Future<void> deleteAccessToken() => _storage.deleteAccessToken();

  Future<void> saveRefreshToken(String token) =>
      _storage.saveRefreshToken(token);
  Future<String?> getRefreshToken() => _storage.getRefreshToken();
  Future<void> deleteRefreshToken() => _storage.deleteRefreshToken();
}
