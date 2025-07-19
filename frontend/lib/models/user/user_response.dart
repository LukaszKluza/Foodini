import 'package:frontend/models/user/language.dart';

class UserResponse {
  final int id;
  final String name;
  final Language language;
  final String email;

  UserResponse({
    required this.id,
    required this.name,
    required this.language,
    required this.email,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'],
      language: Language.fromJson(json['language']),
      email: json['email'],
    );
  }
}
