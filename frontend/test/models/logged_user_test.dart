import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/logged_user.dart';

void main() {
  group('LoggedUser', () {
    test('should parse correctly from JSON with int id', () {
      final json = {
        'id': 42,
        'email': 'test@example.com',
        'access_token': 'access123',
        'refresh_token': 'refresh456',
      };

    final user = LoggedUser.fromJson(json);

    expect(user.id, 42);
    expect(user.email, 'test@example.com');
    expect(user.accessToken, 'access123');
    expect(user.refreshToken, 'refresh456');
  });

  test('should parse correctly from JSON with string id', () {
    final json = {
      'id': '42',
      'email': 'string@example.com',
      'access_token': 'access789',
      'refresh_token': 'refresh987',
    };

    final user = LoggedUser.fromJson(json);

    expect(user.id, 42);
    expect(user.email, 'string@example.com');
    expect(user.accessToken, 'access789');
    expect(user.refreshToken, 'refresh987');
  });
  });
}
