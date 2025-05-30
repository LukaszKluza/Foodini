import 'package:frontend/api_exception.dart';
import 'package:frontend/models/language.dart';

abstract class AccountState {}

class AccountInitial extends AccountState {}

class AccountActionInProgress extends AccountState {}

class AccountLogoutSuccess extends AccountState {}

class AccountChangeLanguageSuccess extends AccountState {
  final Language language;

  AccountChangeLanguageSuccess(this.language);
}

class AccountDeleteSuccess extends AccountState {}

class AccountFailure extends AccountState {
  final ApiException error;

  AccountFailure(this.error);
}
