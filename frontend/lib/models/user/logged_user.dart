import 'package:uuid/uuid_value.dart';

class LoggedUser {
  final UuidValue id;
  final String email;
  final String accessToken;
  final String refreshToken;

  LoggedUser({
    required this.id,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoggedUser.fromJson(Map<String, dynamic> json) {
    return LoggedUser(
      id: UuidValue.fromString(json['id']),
      email: json['email'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}
