class RegisterRequest {
  final String name;
  final String lastName;
  final String country;
  final String email;
  final String password;

  RegisterRequest({
    required this.name,
    required this.lastName,
    required this.country,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'last_name': lastName,
    'country': country,
    'email': email,
    'password': password,
  };
}
