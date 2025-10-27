import 'package:frontend/models/user/language.dart';

class RegisterRequest {
  final String name;
  final String lastName;
  final String country;
  final String email;
  final String password;
  final Language language;

  RegisterRequest({
    required this.name,
    required this.lastName,
    required this.country,
    required this.email,
    required this.password,
    required this.language,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'last_name': lastName,
    'country': country,
    'email': email,
    'password': password,
    'language': language,
  };
}
