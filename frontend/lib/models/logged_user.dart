class LoggedUser {
  final int id;
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
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}