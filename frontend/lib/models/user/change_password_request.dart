import 'package:uuid/uuid_value.dart';

class ChangePasswordRequest {
  final String email;
  final String newPassword;
  final String token;
  final UuidValue? id;

  ChangePasswordRequest({
    required this.email,
    required this.newPassword,
    required this.token,
    this.id,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': newPassword,
    'token': token,
    'id': id?.uuid,
  };
}
