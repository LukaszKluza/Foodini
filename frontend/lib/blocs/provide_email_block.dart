import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/provide_email_events.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/states/provide_email_states.dart';

import '../config/app_config.dart';

class ProvideEmailBloc extends Bloc<ProvideEmailEvent?, ProvideEmailState> {
  final AuthRepository authRepository;

  ProvideEmailBloc(this.authRepository) : super(ProvideEmailInitial()) {
    on<ProvideEmailSubmitted>((event, emit) async {
      emit(ProvideEmailLoading());
      try {
        final response = await authRepository.provideEmail(event.request);

        emit(ProvideEmailSuccess(response));
      } on ApiException catch (error) {
        emit(ProvideEmailFailure(error));
      }
    });
  }
}
