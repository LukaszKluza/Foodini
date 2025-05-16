import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/models/provide_email_request.dart';
import 'package:frontend/models/register_request.dart';
import 'package:frontend/services/api_client.dart';

import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  late MockDio mockDio;
  late MockTokenStorageRepository mockTokenStorage;
  late ApiClient apiClient;

  setUp(() {
    mockDio = MockDio();
    mockTokenStorage = MockTokenStorageRepository();

    when(mockDio.interceptors).thenReturn(Interceptors());
    apiClient = ApiClient(mockDio, mockTokenStorage);
  });

  test('should send a POST request with correct headers and body', () async {
    final request = RegisterRequest(
      name: 'John',
      lastName: 'Doe',
      age: 30,
      country: 'Poland',
      email: 'john.doe@example.com',
      password: 'securepassword123',
    );

    final expectedResponse = Response(
      requestOptions: RequestOptions(path: AppConfig.registerUrl),
      data: {"result": "ok"},
      statusCode: 200,
    );

    when(
      mockDio.post(
        AppConfig.registerUrl,
        data: request.toJson(),
        options: anyNamed('options'),
      ),
    ).thenAnswer((_) async => expectedResponse);

    final response = await apiClient.register(request);

    expect(response.statusCode, 200);
    expect(response.data['result'], 'ok');

    verify(
      mockDio.post(
        AppConfig.registerUrl,
        data: request.toJson(),
        options: anyNamed('options'),
      ),
    ).called(1);
  });

  test('should call logout endpoint with correct user id', () async {
    const userId = 2;
    final url = AppConfig.logoutUrl;

    final expectedResponse = Response(
      requestOptions: RequestOptions(path: url),
      data: null,
      statusCode: 204,
    );

    when(
      mockDio.get(
        url,
        queryParameters: {'user_id': userId},
        options: anyNamed('options'),
      ),
    ).thenAnswer((_) async => expectedResponse);

    final response = await apiClient.logout(userId);

    expect(response.statusCode, 204);

    verify(
      mockDio.get(
        url,
        queryParameters: {'user_id': userId},
        options: anyNamed('options'),
      ),
    ).called(1);
  });

  test('should throw if logout returns error status code', () async {
    const userId = 2;
    final url = AppConfig.logoutUrl;

    when(
      mockDio.get(
        url,
        queryParameters: {'user_id': userId},
        options: anyNamed('options'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: url),
        response: Response(
          requestOptions: RequestOptions(path: url),
          statusCode: 500,
          data: 'error',
        ),
        type: DioExceptionType.badResponse,
      ),
    );

    expect(
      () async => await apiClient.logout(userId),
      throwsA(isA<DioException>()),
    );
  });

  test('should call refreshTokens with Authorization header', () async {
    const testRefreshToken = 'test-refresh-token';

    when(
      mockTokenStorage.getRefreshToken(),
    ).thenAnswer((_) async => testRefreshToken);

    final expectedResponse = Response(
      requestOptions: RequestOptions(path: AppConfig.refreshTokensUrl),
      statusCode: 200,
      data: {
        'access_token': 'new-access-token',
        'refresh_token': 'new-refresh-token',
      },
    );

    when(
      mockDio.post(AppConfig.refreshTokensUrl, options: anyNamed('options')),
    ).thenAnswer((_) async => expectedResponse);

    final response = await apiClient.refreshTokens();

    expect(response.statusCode, 200);
    expect(response.data['access_token'], 'new-access-token');

    verify(
      mockDio.post(
        AppConfig.refreshTokensUrl,
        options: argThat(
          predicate<Options>(
            (opt) =>
                opt.headers?['Authorization'] == 'Bearer $testRefreshToken',
          ),
          named: 'options',
        ),
      ),
    ).called(1);
  });

  test('should call getUser with requiresAuth set to true', () async {
    final expectedResponse = Response(
      requestOptions: RequestOptions(path: AppConfig.getUserUrl),
      data: {'name': 'Jane', 'email': 'jane@example.com'},
      statusCode: 200,
    );

    when(
      mockDio.get(AppConfig.getUserUrl, options: anyNamed('options')),
    ).thenAnswer((_) async => expectedResponse);

    final response = await apiClient.getUser();

    expect(response.statusCode, 200);
    expect(response.data['email'], 'jane@example.com');

    verify(
      mockDio.get(
        AppConfig.getUserUrl,
        options: argThat(
          predicate<Options>((opt) => opt.extra?['requiresAuth'] == true),
          named: 'options',
        ),
      ),
    ).called(1);
  });

  test('should call provideEmail endpoint with correct body', () async {
    final request = ProvideEmailRequest(email: 'test@example.com');

    final expectedResponse = Response(
      requestOptions: RequestOptions(path: AppConfig.changePasswordUrl),
      data: {'status': 'email sent'},
      statusCode: 200,
    );

    when(
      mockDio.post(
        AppConfig.changePasswordUrl,
        data: request.toJson(),
        options: anyNamed('options'),
      ),
    ).thenAnswer((_) async => expectedResponse);

    final response = await apiClient.provideEmail(request);

    expect(response.statusCode, 200);
    expect(response.data['status'], 'email sent');

    verify(
      mockDio.post(
        AppConfig.changePasswordUrl,
        data: request.toJson(),
        options: anyNamed('options'),
      ),
    ).called(1);
  });

  test('should call resendVerificationMail with correct query param', () async {
    const email = 'test@example.com';

    final expectedResponse = Response(
      requestOptions: RequestOptions(
        path: AppConfig.resendVerificationEmailUrl,
      ),
      data: {'status': 'resent'},
      statusCode: 200,
    );

    when(
      mockDio.get(
        AppConfig.resendVerificationEmailUrl,
        queryParameters: {'email': email},
        options: anyNamed('options'),
      ),
    ).thenAnswer((_) async => expectedResponse);

    final response = await apiClient.resendVerificationMail(email);

    expect(response.statusCode, 200);
    expect(response.data['status'], 'resent');

    verify(
      mockDio.get(
        AppConfig.resendVerificationEmailUrl,
        queryParameters: {'email': email},
        options: anyNamed('options'),
      ),
    ).called(1);
  });

  test('should call delete endpoint with correct user id', () async {
    const userId = 42;

    final expectedResponse = Response(
      requestOptions: RequestOptions(path: '${AppConfig.deleteUrl}/$userId'),
      statusCode: 204,
    );

    when(
      mockDio.delete(
        '${AppConfig.deleteUrl}/$userId',
        options: anyNamed('options'),
      ),
    ).thenAnswer((_) async => expectedResponse);

    final response = await apiClient.delete(userId);

    expect(response.statusCode, 204);

    verify(
      mockDio.delete(
        '${AppConfig.deleteUrl}/$userId',
        options: anyNamed('options'),
      ),
    ).called(1);
  });
}
