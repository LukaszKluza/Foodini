import 'package:frontend/models/change_language_request.dart';

abstract class AccountEvent {}

class AccountLogoutRequested extends AccountEvent {}
class AccountChangeLanguageRequested extends AccountEvent {
  final ChangeLanguageRequest request;

  AccountChangeLanguageRequested(this.request);
}
class AccountDeleteRequested extends AccountEvent {}
