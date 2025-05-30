import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/register_events.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/states/register_states.dart';

class RegisterBloc extends Bloc<RegisterEvent?, RegisterState> {
  final AuthRepository authRepository;

  RegisterBloc(this.authRepository) : super(RegisterInitial()) {
    on<RegisterSubmitted>((event, emit) async {
      emit(RegisterLoading());
      try {
        await authRepository.register(event.request);

        emit(RegisterSuccess());
      } on ApiException catch (error) {
        emit(RegisterFailure(error));
      }
    });
  }
}
