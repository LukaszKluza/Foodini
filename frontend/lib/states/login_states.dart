import 'package:frontend/api_exception.dart';

abstract class LoginState {
  final String? message;
  const LoginState({this.message});
}

class LoginInitial extends LoginState {}

class ActionInProgress extends LoginState {}

class LoginSuccess extends LoginState {
  LoginSuccess(String message) : super(message: message);
}

class LoginFailure extends LoginState {
  final ApiException error;

  LoginFailure(this.error);
}

class AccountSuccessVerification extends LoginState {
  AccountSuccessVerification(String message) : super(message: message);
}

class AccountNotVerified extends LoginState {
  AccountNotVerified();
}

class ResendAccountVerificationSuccess extends LoginState {
  ResendAccountVerificationSuccess(String message) : super(message: message);
}
