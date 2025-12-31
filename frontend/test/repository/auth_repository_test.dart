import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/user/login_request.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid_value.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  late UuidValue uuidUserId;
  late MockApiClient mockApiClient;
  late UserRepository authRepository;

  setUp(() {
    mockApiClient = MockApiClient();
    authRepository = UserRepository(mockApiClient);

    uuidUserId = UuidValue.fromString('c4b678c3-bb44-5b37-90d9-5b0c9a4f1b87');
  });

  test('login returns LoggedUser on success', () async {
    final loginRequest = LoginRequest(
      username: 'test@example.com',
      password: 'pass123',
    );

    final responsePayload = {
      'id': uuidUserId.uuid,
      'email': 'test@example.com',
      'access_token': 'abc',
      'refresh_token': 'xyz',
    };

    when(mockApiClient.login(loginRequest)).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: responsePayload,
        statusCode: 200,
      ),
    );

    final user = await authRepository.login(loginRequest);

    expect(user.email, 'test@example.com');
    expect(user.accessToken, 'abc');
    verify(mockApiClient.login(loginRequest)).called(1);
  });

  test('refreshTokens returns RefreshedTokensResponse on success', () async {
    final responsePayload = {
      'access_token': 'newAccessToken',
      'refresh_token': 'newRefreshToken',
    };

    when(mockApiClient.refreshTokens(uuidUserId)).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: responsePayload,
        statusCode: 200,
      ),
    );

    final result = await authRepository.refreshTokens(uuidUserId);

    expect(result.accessToken, 'newAccessToken');
    expect(result.refreshToken, 'newRefreshToken');
    verify(mockApiClient.refreshTokens(uuidUserId)).called(1);
  });
}
