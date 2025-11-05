import 'package:uuid/uuid.dart';

class DefaultResponse {
  final UuidValue id;
  final String email;

  DefaultResponse({required this.id, required this.email});

  factory DefaultResponse.fromJson(Map<String, dynamic> json) {
    return DefaultResponse(
      id: UuidValue.fromString(json['id']),
      email: json['email'],
    );
  }
}
