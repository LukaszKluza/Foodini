import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/repository/user_storage.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/utils/global_error_interceptor.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:frontend/blocs/account_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/services/token_storage_service.dart';

import '../mocks/mocks.mocks.dart';

late MockDio mockDio;
late AccountBloc accountBloc;
late ApiClient apiClient;
late AuthRepository authRepository;
late UserStorage userStorage;
late MockTokenStorageRepository mockTokenStorageRepository;

Widget wrapWithProviders(Widget child) {
  return MultiProvider(
    providers: [
      Provider<AuthRepository>.value(value: authRepository),
      Provider<TokenStorageRepository>.value(value: mockTokenStorageRepository),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  setUp(() {
    mockDio = MockDio();
    when(mockDio.interceptors).thenReturn(Interceptors());

    mockTokenStorageRepository = MockTokenStorageRepository();
    apiClient = ApiClient(mockDio, mockTokenStorageRepository);

    userStorage = UserStorage();
    authRepository = AuthRepository(apiClient);
    accountBloc = AccountBloc(authRepository, mockTokenStorageRepository);
  });

  testWidgets('Should retry when access token revoke', (
    WidgetTester tester,
  ) async {
    when(
      mockDio.get(
        AppConfig.logoutUrl,
        queryParameters: {'user_id': 1},
        options: anyNamed('options'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: AppConfig.logoutUrl),
        response: Response(
          requestOptions: RequestOptions(
            path: AppConfig.logoutUrl,
            queryParameters: {'user_id': 1},
          ),
          statusCode: 401,
          data: 'Unauthorized',
        ),
        type: DioExceptionType.badResponse,
      ),
    );

    when(
      mockTokenStorageRepository.getRefreshToken(),
    ).thenAnswer((_) async => 'refresh_token');

    when(
      mockDio.post(AppConfig.refreshTokensUrl, options: anyNamed('options')),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: AppConfig.refreshTokensUrl),
        data: {
          'access_token': 'access_token',
          'refresh_token': 'refresh_token',
        },
        statusCode: 200,
      ),
    );

    when(
      mockDio.request(
        AppConfig.logoutUrl,
        queryParameters: {'user_id': 1},
        options: anyNamed('options'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: AppConfig.logoutUrl),
        statusCode: 204,
      ),
    );

    // When
    try {
      await apiClient.logout(1);
    } catch (e) {
      expect(e, isA<DioException>());
      final handler = MockErrorInterceptorHandler();
      final interceptor = GlobalErrorInterceptor(
        apiClient,
        mockTokenStorageRepository,
      );

      await interceptor.onError(e as DioException, handler);
    }

    verify(
      mockDio.get(
        AppConfig.logoutUrl,
        queryParameters: {'user_id': 1},
        options: anyNamed('options'),
      ),
    ).called(1);

    verify(
      mockDio.post(AppConfig.refreshTokensUrl, options: anyNamed('options')),
    ).called(1);

    verify(
      mockDio.request(
        AppConfig.logoutUrl,
        queryParameters: {'user_id': 1},
        options: anyNamed('options'),
      ),
    ).called(1);
  });

  testWidgets('Should show session expired if no refresh token is available', (
    tester,
  ) async {
    final error = DioException(
      requestOptions: RequestOptions(path: '/some-path'),
      response: Response(
        requestOptions: RequestOptions(path: '/some-path'),
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );

    when(
      mockTokenStorageRepository.getRefreshToken(),
    ).thenAnswer((_) async => null);
    final handler = MockErrorInterceptorHandler();
    final interceptor = GlobalErrorInterceptor(
      apiClient,
      mockTokenStorageRepository,
    );

    await interceptor.onError(error, handler);

    verify(mockTokenStorageRepository.getRefreshToken()).called(1);
    verifyNever(
      mockDio.post(AppConfig.refreshTokensUrl, options: anyNamed('options')),
    );
  });
}
