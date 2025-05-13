import 'package:frontend/api_exception.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String message;

  LoginSuccess(this.message);
}

class LoginFailure extends LoginState {
  final ApiException error;

  LoginFailure(this.error);
}

class AccountNotVerified extends LoginFailure {
  AccountNotVerified(super.error);
}

class ResendAccountVerificationSuccess extends LoginState {
  final String message;

  ResendAccountVerificationSuccess(this.message);
}
