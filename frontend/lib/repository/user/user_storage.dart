import 'package:frontend/models/user/user_response.dart';

class UserStorage {
  static final UserStorage _instance = UserStorage._internal();

  factory UserStorage() {
    return _instance;
  }

  UserStorage._internal();

  UserResponse? _user;

  UserResponse? get user => _user;

  bool get isLoggedIn => _user != null;

  UserResponse? get getUser => _user;

  int? get getUserId => _user?.id;

  void setUser(UserResponse user) {
    _user = user;
  }

  void removeUser() {
    _user = null;
  }
}
