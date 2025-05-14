import 'package:frontend/models/login_request.dart';

abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final LoginRequest request;

  LoginSubmitted(this.request);
}

class ResendVerificationEmail extends LoginEvent {
  final String email;

  ResendVerificationEmail(this.email);
}

class InitFromUrl extends LoginEvent {
  final String? status;
  InitFromUrl(this.status);
}
