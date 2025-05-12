class RegisterRequest {
  final String name;
  final String lastName;
  final int age;
  final String country;
  final String email;
  final String password;

  RegisterRequest({
    required this.name,
    required this.lastName,
    required this.age,
    required this.country,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "last_name": lastName,
    "age": age,
    "country": country,
    "email": email,
    "password": password,
  };
}