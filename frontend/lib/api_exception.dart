class ApiException implements Exception {
  final dynamic data;
  final int? statusCode;

  ApiException(this.data, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return '$data (status: $statusCode)';
    }
    return data.toString();
  }
}
