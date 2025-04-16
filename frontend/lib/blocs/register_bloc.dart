import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/register_events.dart';
import 'package:frontend/states/register_states.dart';

import '../repository/auth_repository.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository authRepository;

  RegisterBloc(this.authRepository) : super(RegisterInitial()) {
    on<RegisterSubmitted>((event, emit) async {
      emit(RegisterLoading());
      try {
        final response = await authRepository.register(event.request);

        emit(RegisterSuccess(response));
      } on ApiException catch (error) {
        emit(RegisterFailure(error));
      }
    });
  }
}
