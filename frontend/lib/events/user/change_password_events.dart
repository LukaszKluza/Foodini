import 'package:frontend/models/user/change_password_request.dart';

abstract class ChangePasswordEvent {}

class ChangePasswordSubmitted extends ChangePasswordEvent {
  final ChangePasswordRequest request;

  ChangePasswordSubmitted(this.request);
}