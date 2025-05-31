import 'package:frontend/api_exception.dart';
import 'package:frontend/models/user/user_response.dart';

abstract class ProvideEmailState {}

class ProvideEmailInitial extends ProvideEmailState {}

class ProvideEmailLoading extends ProvideEmailState {}

class ProvideEmailSuccess extends ProvideEmailState {
  final UserResponse response;

  ProvideEmailSuccess(this.response);
}

class ProvideEmailFailure extends ProvideEmailState {
  final ApiException error;

  ProvideEmailFailure(this.error);
}
