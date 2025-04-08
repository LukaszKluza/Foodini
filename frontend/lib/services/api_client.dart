import 'dart:convert';
import 'package:frontend/config/app_config.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client;

  ApiClient([http.Client? client]) : _client = client ?? http.Client();

  Future<http.Response> postRequest(Uri url, Map<String, dynamic> body) {
    return _client.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  Future<void> logout(int userId) async {
    final uri = Uri.parse('${AppConfig.logoutUrl}?user_id=$userId');

    final response = await http.get(uri);

    if (response.statusCode != 204) {
      throw Exception('Logout failed: ${response.statusCode}');
    }
  }
}
