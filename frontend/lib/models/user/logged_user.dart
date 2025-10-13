class LoggedUser {
  final int id;
  final String email;
  final String accessToken;

  LoggedUser({
    required this.id,
    required this.email,
    required this.accessToken,
  });

  factory LoggedUser.fromJson(Map<String, dynamic> json) {
    return LoggedUser(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email'],
      accessToken: json['access_token'],
    );
  }
}
