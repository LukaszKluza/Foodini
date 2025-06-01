class DefaultResponse {
  final int id;
  final String email;

  DefaultResponse({
    required this.id,
    required this.email,
  });

  factory DefaultResponse.fromJson(Map<String, dynamic> json) {
    return DefaultResponse(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email'],
    );
  }
}