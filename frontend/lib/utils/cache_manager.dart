import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/repository/api_client.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';

class CacheManager {
  late CacheStore cacheStore;
  late CacheOptions cacheOptions;

  CacheManager(ApiClient apiclient, Directory? apiDir) {

    if (kIsWeb) {
      cacheStore = HiveCacheStore(null);
    } else {
      if (apiDir == null) {
        throw ArgumentError('apiDir cannot be null on mobile/desktop');
      }
      cacheStore = HiveCacheStore(apiDir.path);
    }

    cacheOptions = CacheOptions(
      store: cacheStore,
      policy: CachePolicy.forceCache,
      hitCacheOnErrorCodes: [500, 502, 503, 504],
      maxStale: const Duration(seconds: 1),
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
      allowPostMethod: false,
    );

    apiclient.dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
    apiclient.dio.interceptors.add(InterceptorsWrapper(
      onError: (err, handler) async {
        if (err.response?.statusCode == 401 ||
            err.response?.statusCode == 403) {
          await clearAllCache();
        }
        return handler.next(err);
      },
    ));
  }

  Future<void> clearAllCache() async {
    await cacheStore.clean();
  }

  Future<void> clearCacheFor(Uri url) async {
    final key = CacheOptions.defaultCacheKeyBuilder(url: url);
    await cacheStore.delete(key);
  }
}
