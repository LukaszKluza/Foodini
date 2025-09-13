import 'package:frontend/api_exception.dart';

abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountActionInProgress extends AccountState {}

class AccountLogoutSuccess extends AccountState {}

class AccountDeleteSuccess extends AccountState {}

class AccountFailure extends AccountState {
  final ApiException error;

  AccountFailure(this.error);
}
