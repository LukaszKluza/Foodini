import 'package:flutter/cupertino.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/models/user/user_response.dart';

abstract class LoginState {
  final String Function(BuildContext)? getMessage;
  const LoginState({this.getMessage});
}

class LoginInitial extends LoginState {}

class ActionInProgress extends LoginState {}

class LoginSuccess extends LoginState {
  final UserResponse userResponse;

  LoginSuccess({
    required this.userResponse,
    required String Function(BuildContext) getMessage,
  }) : super(getMessage: getMessage);
}

class LoginFailure extends LoginState {
  final ApiException error;

  LoginFailure(this.error);
}

class AccountSuccessVerification extends LoginState {
  AccountSuccessVerification(String Function(BuildContext) getMessage) : super(getMessage: getMessage);
}

class AccountNotVerified extends LoginState {
  AccountNotVerified();
}

class ResendAccountVerificationSuccess extends LoginState {
  ResendAccountVerificationSuccess(String Function(BuildContext) getMessage) : super(getMessage: getMessage);
}
