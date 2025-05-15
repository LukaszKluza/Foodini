import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/models/register_request.dart';
import 'package:frontend/services/api_client.dart';

import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  late MockDio mockDio;
  late ApiClient apiClient;

  setUp(() {
    mockDio = MockDio();
    when(mockDio.interceptors).thenReturn(Interceptors());
    apiClient = ApiClient(mockDio);
  });

  test('should send a POST request with correct headers and body', () async {
    final request = RegisterRequest(
      name: 'John',
      lastName: 'Doe',
      country: 'Poland',
      email: 'john.doe@example.com',
      password: 'securepassword123',
    );

    final expectedResponse = Response(
      requestOptions: RequestOptions(path: AppConfig.registerUrl),
      data: {"result": "ok"},
      statusCode: 200,
    );

    when(mockDio.interceptors).thenReturn(Interceptors());
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

    expect(() async => await apiClient.logout(2), throwsA(isA<DioException>()));
  });
}
