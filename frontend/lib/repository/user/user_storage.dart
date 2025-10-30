import 'dart:convert';

import 'package:frontend/models/user/language.dart';
import 'package:frontend/models/user/user_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid_value.dart';

class UserStorage {
  static final UserStorage _instance = UserStorage._internal();

  factory UserStorage() {
    return _instance;
  }

  UserStorage._internal();

  UserResponse? _user;

  bool get isLoggedIn => _user != null;

  UserResponse? get getUser => _user;

  UuidValue? get getUserId => _user?.id;

  String? get getName => _user?.name;

  void setUser(UserResponse user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', jsonEncode(user.toJson()));
  }

  void removeUser() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      try {
        _user = UserResponse.fromJson(jsonDecode(userJson));
      } catch (_) {
        removeUser();
      }
    }
  }

  Future<void> updateLanguage(Language newLanguage) async {
    if (_user != null) {
      _user = _user!.copyWith(language: newLanguage);
      setUser(_user!);
    }
  }
}
