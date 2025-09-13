class UserResponse {
  final int id;
  final String email;

  UserResponse({
    required this.id,
    required this.email,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email'],
    );
  }
}