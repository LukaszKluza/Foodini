class QueryParametersMapper {
  static Map<String, String> parseQueryParams(String query) {
    final Map<String, String> queryParameters = {};

    final pairs = query.split('&');

    for (var pair in pairs) {
      final keyValue = pair.split('=');
      if (keyValue.length >= 2) {
        queryParameters[keyValue[0]] = keyValue[1];
      }
    }

    return queryParameters;
  }
}