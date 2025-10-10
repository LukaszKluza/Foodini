import 'package:frontend/models/user/language.dart';

class ChangeLanguageRequest {
  final Language language;

  ChangeLanguageRequest({required this.language});

  Map<String, dynamic> toJson() => {'language': language.toJson()};
}
