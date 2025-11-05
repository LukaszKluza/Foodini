class ProvideEmailRequest {
  final String email;

  ProvideEmailRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}
