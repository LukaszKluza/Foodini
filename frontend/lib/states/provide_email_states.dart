import 'package:frontend/api_exception.dart';
import 'package:frontend/models/user/default_response.dart';

abstract class ProvideEmailState {}

class ProvideEmailInitial extends ProvideEmailState {}

class ProvideEmailLoading extends ProvideEmailState {}

class ProvideEmailSuccess extends ProvideEmailState {
  final DefaultResponse response;

  ProvideEmailSuccess(this.response);
}

class ProvideEmailFailure extends ProvideEmailState {
  final ApiException error;

  ProvideEmailFailure(this.error);
}
