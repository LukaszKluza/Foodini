import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/models/user/logged_user.dart';
import 'package:uuid/uuid_value.dart';

void main() {
  final UuidValue uuidUserId = UuidValue.fromString('c4b678c3-bb44-5b37-90d9-5b0c9a4f1b87');

  group('LoggedUser', () {
    test('should parse correctly from JSON with int id', () {
      final json = {
        'id': uuidUserId.uuid,
        'email': 'test@example.com',
        'access_token': 'access123',
        'refresh_token': 'refresh456',
      };

      final user = LoggedUser.fromJson(json);

      expect(user.id, uuidUserId);
      expect(user.email, 'test@example.com');
      expect(user.accessToken, 'access123');
      expect(user.refreshToken, 'refresh456');
    });

    test('should parse correctly from JSON with string id', () {
      final json = {
        'id': uuidUserId.uuid,
        'email': 'string@example.com',
        'access_token': 'access789',
        'refresh_token': 'refresh987',
      };

      final user = LoggedUser.fromJson(json);

      expect(user.id, uuidUserId);
      expect(user.email, 'string@example.com');
      expect(user.accessToken, 'access789');
      expect(user.refreshToken, 'refresh987');
    });
  });
}
