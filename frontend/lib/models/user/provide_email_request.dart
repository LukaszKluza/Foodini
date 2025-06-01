class ProvideEmailRequest {
  final String email;
  final int? id;

  ProvideEmailRequest({
    required this.email,
    this.id,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'id': id,
  };
}