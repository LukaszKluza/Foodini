class ApiException implements Exception {
  final dynamic data;

  ApiException(this.data);

  @override
  String toString() => data.toString();
}
