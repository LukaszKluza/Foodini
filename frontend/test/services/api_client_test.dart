import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/models/user/provide_email_request.dart';
import 'package:frontend/models/user/register_request.dart';
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
      country: 'Poland',
      email: 'john.doe@example.com',
      password: 'securepassword123',
    );

    final expectedResponse = Response(
      requestOptions: RequestOptions(path: Endpoints.register),
      data: {"result": "ok"},
      statusCode: 200,
    );

    when(
      mockDio.post(
        Endpoints.register,
        data: request.toJson(),
        options: anyNamed('options'),
      ),
    ).thenAnswer((_) async => expectedResponse);

    final response = await apiClient.register(request);

    expect(response.statusCode, 200);
    expect(response.data['result'], 'ok');

    verify(
      mockDio.post(
        Endpoints.register,
        data: request.toJson(),
        options: anyNamed('options'),
      ),
    ).called(1);
  });

  test('should call logout endpoint with correct user id', () async {
    const userId = 2;
    final url = Endpoints.logout;

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
    final url = Endpoints.logout;

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
      requestOptions: RequestOptions(path: Endpoints.refreshTokens),
      statusCode: 200,
      data: {
        'access_token': 'new-access-token',
        'refresh_token': 'new-refresh-token',
      },
    );

    when(
      mockDio.post(Endpoints.refreshTokens, options: anyNamed('options')),
    ).thenAnswer((_) async => expectedResponse);

    final response = await apiClient.refreshTokens();

    expect(response.statusCode, 200);
    expect(response.data['access_token'], 'new-access-token');

    verify(
      mockDio.post(
        Endpoints.refreshTokens,
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
      requestOptions: RequestOptions(path: Endpoints.getUser),
      data: {'name': 'Jane', 'email': 'jane@example.com'},
      statusCode: 200,
    );

    when(
      mockDio.get(Endpoints.getUser, options: anyNamed('options')),
    ).thenAnswer((_) async => expectedResponse);

    final response = await apiClient.getUser();

    expect(response.statusCode, 200);
    expect(response.data['email'], 'jane@example.com');

    verify(
      mockDio.get(
        Endpoints.getUser,
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
      requestOptions: RequestOptions(path: Endpoints.changePassword),
      data: {'status': 'email sent'},
      statusCode: 200,
    );

    when(
      mockDio.post(
        Endpoints.changePassword,
        data: request.toJson(),
        options: anyNamed('options'),
      ),
    ).thenAnswer((_) async => expectedResponse);

    final response = await apiClient.provideEmail(request);

    expect(response.statusCode, 200);
    expect(response.data['status'], 'email sent');

    verify(
      mockDio.post(
        Endpoints.changePassword,
        data: request.toJson(),
        options: anyNamed('options'),
      ),
    ).called(1);
  });

  test('should call resendVerificationMail with correct query param', () async {
    const email = 'test@example.com';

    final expectedResponse = Response(
      requestOptions: RequestOptions(
        path: Endpoints.resendVerificationEmail,
      ),
      data: {'status': 'resent'},
      statusCode: 200,
    );

    when(
      mockDio.get(
        Endpoints.resendVerificationEmail,
        queryParameters: {'email': email},
        options: anyNamed('options'),
      ),
    ).thenAnswer((_) async => expectedResponse);

    final response = await apiClient.resendVerificationMail(email);

    expect(response.statusCode, 200);
    expect(response.data['status'], 'resent');

    verify(
      mockDio.get(
        Endpoints.resendVerificationEmail,
        queryParameters: {'email': email},
        options: anyNamed('options'),
      ),
    ).called(1);
  });

  test('should call delete endpoint with correct user id', () async {
    const userId = 42;

    final expectedResponse = Response(
      requestOptions: RequestOptions(path: '${Endpoints.delete}/$userId'),
      statusCode: 204,
    );

    when(
      mockDio.delete(
        '${Endpoints.delete}/$userId',
        options: anyNamed('options'),
      ),
    ).thenAnswer((_) async => expectedResponse);

    final response = await apiClient.delete(userId);

    expect(response.statusCode, 204);

    verify(
      mockDio.delete(
        '${Endpoints.delete}/$userId',
        options: anyNamed('options'),
      ),
    ).called(1);
  });
}
