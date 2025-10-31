import 'package:frontend/models/user/language.dart';
import 'package:uuid/uuid_value.dart';

class UserResponse {
  final UuidValue id;
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
      id: UuidValue.fromString(json['id']),
      name: json['name'],
      language: Language.fromJson(json['language']),
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.uuid,
      'name': name,
      'language': language.toJson(),
      'email': email,
    };
  }

  UserResponse copyWith({
    UuidValue? id,
    String? name,
    Language? language,
    String? email,
  }) {
    return UserResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      language: language ?? this.language,
      email: email ?? this.email,
    );
  }
}
