import 'package:frontend/api_exception.dart';

abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountLoggingOut extends AccountState {}

class AccountLogoutSuccess extends AccountState {}

class AccountLogoutFailure extends AccountState {
  final ApiException error;

  AccountLogoutFailure(this.error);
}
