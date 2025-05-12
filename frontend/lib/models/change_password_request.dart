class ChangePasswordRequest {
  final String email;
  final int? id;

  ChangePasswordRequest({
    required this.email,
    this.id,
  });

  Map<String, dynamic> toJson() => {
    "email": email,
    "id": id,
  };
}