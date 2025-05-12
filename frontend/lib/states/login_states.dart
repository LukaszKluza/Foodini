import 'package:frontend/api_exception.dart';
import 'package:frontend/models/logged_user.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoggedUser loggedUser;

  LoginSuccess(this.loggedUser);
}

class LoginFailure extends LoginState {
  final ApiException error;

  LoginFailure(this.error);
}
