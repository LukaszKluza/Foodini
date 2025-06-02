import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/repository/user/token_storage_mobile_repository.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  late MockFlutterSecureStorage mockStorage;
  late TokenStorageMobile tokenStorageMobile;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    tokenStorageMobile = TokenStorageMobile(storage: mockStorage);
  });

  test('saveAccessToken stores token', () async {
    when(mockStorage.write(key: "abc123", value: "access_token"))
        .thenAnswer((_) async {});

    await tokenStorageMobile.saveAccessToken('abc123');
    verify(mockStorage.write(key: 'access_token', value: 'abc123')).called(1);
  });

  test('getAccessToken retrieves token', () async {
    when(mockStorage.read(key: 'access_token')).thenAnswer((_) async => 'xyz789');

    final token = await tokenStorageMobile.getAccessToken();
    expect(token, 'xyz789');
  });

  test('deleteAccessToken deletes token', () async {
    await tokenStorageMobile.deleteAccessToken();
    verify(mockStorage.delete(key: 'access_token')).called(1);
  });
}
