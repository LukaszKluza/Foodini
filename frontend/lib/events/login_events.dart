import 'package:frontend/models/login_request.dart';

abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final LoginRequest request;

  LoginSubmitted(this.request);
}
