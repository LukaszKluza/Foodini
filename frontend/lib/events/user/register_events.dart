import 'package:frontend/models/user/register_request.dart';

abstract class RegisterEvent {}

class RegisterSubmitted extends RegisterEvent {
  final RegisterRequest request;

  RegisterSubmitted(this.request);
}
