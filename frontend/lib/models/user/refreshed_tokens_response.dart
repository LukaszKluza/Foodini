class RefreshedTokensResponse {
  final String accessToken;
  final String refreshToken;

  RefreshedTokensResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() => {
    "access_token": accessToken,
    "refresh_token": refreshToken,
  };

  factory RefreshedTokensResponse.fromJson(Map<String, dynamic> json) {
    return RefreshedTokensResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}