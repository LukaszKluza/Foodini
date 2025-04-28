import 'package:frontend/models/logged_user.dart';

class UserStorage {
  static final UserStorage _instance = UserStorage._internal();

  factory UserStorage() {
    return _instance;
  }

  UserStorage._internal();

  LoggedUser? _user;

  LoggedUser? get user => _user;

  bool get isLoggedIn => _user != null;

  LoggedUser? get getUser => _user;

  int? get getUserId => _user?.id;

  void setUser(LoggedUser user) {
    _user = user;
  }

  void removeUser() {
    _user = null;
  }
}
