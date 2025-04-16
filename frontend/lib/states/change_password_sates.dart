import 'package:frontend/api_exception.dart';
import 'package:frontend/models/user_response.dart';

abstract class ChangePasswordState {}

class ChangePasswordInitial extends ChangePasswordState {}

class ChangePasswordLoading extends ChangePasswordState {}

class ChangePasswordSuccess extends ChangePasswordState {
  final UserResponse response;

  ChangePasswordSuccess(this.response);
}

class ChangePasswordFailure extends ChangePasswordState {
  final ApiException error;

  ChangePasswordFailure(this.error);
}
