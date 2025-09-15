import 'dart:convert';

import 'package:frontend/models/user_details/diet_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DietFormStorage {
  static final DietFormStorage _instance = DietFormStorage._internal();

  factory DietFormStorage() {
    return _instance;
  }

  DietFormStorage._internal();

  DietForm? _form;

  DietForm? get getForm => _form;

  bool get hasForm => _form != null;

  Future<void> saveForm(DietForm form) async {
    _form = form;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('diet_form');
  }

  Future<void> removeForm() async {
    _form = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('diet_form');
  }

  Future<void> loadForm() async {
    final prefs = await SharedPreferences.getInstance();
    final formJson = prefs.getString('diet_form');
    if (formJson != null) {
      _form = DietForm.fromJson(jsonDecode(formJson));
    }
  }
}
