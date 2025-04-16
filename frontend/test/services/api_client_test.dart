import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/models/register_request.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/services/api_client.dart';
import '../mocks/mocks.mocks.dart';

void main() {
  late MockClient mockClient;
  late ApiClient apiClient;

  setUp(() {
    mockClient = MockClient();
    apiClient = ApiClient(mockClient);
  });

  test('should send a POST request with correct headers and body', () async {
    final url = Uri.parse('https://example.com/post');
    final body = RegisterRequest(
      name: 'John',
      lastName: 'Doe',
      age: 30,
      country: 'Poland',
      email: 'john.doe@example.com',
      password: 'securepassword123',
    );

    when(
      mockClient.post(
        url,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenAnswer((_) async => http.Response('{"result": "ok"}', 200));

    final response = await apiClient.register(body);

    expect(response.statusCode, 200);
    verify(
      mockClient.post(
        Uri.parse(AppConfig.registerUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      ),
    ).called(1);
  });

  // test('should call logout endpoint and not throw if status is 204', () async {
  //   final url = Uri.parse('${AppConfig.logoutUrl}?user_id=123');

  //   when(mockClient.get(url)).thenAnswer((_) async => http.Response('', 204));

  //   await apiClient.logout(123);

  //   verify(mockClient.get(url)).called(1);
  // });

  test('should throw if status is not 204', () async {
    final url = Uri.parse('${AppConfig.logoutUrl}?user_id=123');

    when(
      mockClient.get(url),
    ).thenAnswer((_) async => http.Response('error', 500));

    expect(() => apiClient.logout(123), throwsException);
  });
}
