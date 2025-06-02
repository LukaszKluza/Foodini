import 'package:frontend/api_exception.dart';

abstract class ChangePasswordState {
  final String? message;
  const ChangePasswordState({this.message});
}

class ChangePasswordInitial extends ChangePasswordState {}

class ChangePasswordLoading extends ChangePasswordState {}

class ChangePasswordSuccess extends ChangePasswordState {}

class ChangePasswordFailure extends ChangePasswordState {
  final ApiException error;

  ChangePasswordFailure(this.error);
}
