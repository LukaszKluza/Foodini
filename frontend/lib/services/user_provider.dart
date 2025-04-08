import 'package:flutter/material.dart';
import 'package:frontend/models/logged_user.dart';

class UserProvider with ChangeNotifier {
  LoggedUser? _user;

  LoggedUser? get user => _user;

  bool get isLoggedIn => _user != null;

  void setUser(LoggedUser user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
