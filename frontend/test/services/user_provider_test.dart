import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/logged_user.dart';
import 'package:frontend/services/user_provider.dart';

void main() {
    test('should set user correctly', () {
      final userProvider = UserProvider();

      final user = LoggedUser(
        id: 1,
        email: 'test@example.com',
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
      );

      userProvider.setUser(user);

      expect(userProvider.user, equals(user));
      expect(userProvider.isLoggedIn, isTrue);
    });

    test('should logout user correctly', () {
      final userProvider = UserProvider();

      final user = LoggedUser(
        id: 1,
        email: 'test@example.com',
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
      );

      userProvider.setUser(user);

      expect(userProvider.isLoggedIn, isTrue);

      userProvider.logout();

      expect(userProvider.user, isNull);
      expect(userProvider.isLoggedIn, isFalse);
    });

    test('should notify listeners when user is set', () {
      final userProvider = UserProvider();

      expect(userProvider.hasListeners, isFalse);

      final user = LoggedUser(
        id: 1,
        email: 'test@example.com',
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
      );

      userProvider.addListener(() {});

      userProvider.setUser(user);

      expect(userProvider.hasListeners, isTrue);
    });
}
