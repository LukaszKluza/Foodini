import 'package:frontend/api_exception.dart';
import 'package:frontend/models/user_response.dart';

abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  // final UserResponse userResponse;
  //
  // RegisterSuccess(this.userResponse);
}

class RegisterFailure extends RegisterState {
  final ApiException error;

  RegisterFailure(this.error);
}
