
class Endpoints {
  static const String baseUrl = String.fromEnvironment('baseUrl');
  static const String register = '$baseUrl/users/register';
  static const String login = '$baseUrl/users/login';
  static const String logout = '$baseUrl/users/logout';
  static const String getUser = '$baseUrl/users/';
  static const String resendVerificationEmail = '$baseUrl/users/confirm/resend-verification-new-account';
  static const String delete = '$baseUrl/users/delete';
  static const String changePassword = '$baseUrl/users/reset-password/request';
  static const String changeLanguage = '$baseUrl/users/change/language';
  static const String confirmNewPassword = '$baseUrl/users/confirm/new-password';
  static const String refreshTokens = '$baseUrl/users/refresh-tokens';
}
