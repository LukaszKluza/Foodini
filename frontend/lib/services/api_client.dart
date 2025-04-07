import 'dart:convert';
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
}
