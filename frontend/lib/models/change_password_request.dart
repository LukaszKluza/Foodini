class ChangePasswordRequest {
  final String email;
  final String newPassword;
  final int? id;

  ChangePasswordRequest({
    required this.email,
    required this.newPassword,
    this.id,
  });

  Map<String, dynamic> toJson() => {
    "email": email,
    "password": newPassword,
    "id": id,
  };
}