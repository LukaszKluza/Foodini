import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/provide_email_events.dart';
import 'package:frontend/fetch_token_task_callback.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/provide_email_states.dart';

class ProvideEmailBloc extends Bloc<ProvideEmailEvent?, ProvideEmailState> {
  final AuthRepository authRepository;

  ProvideEmailBloc(
    this.authRepository, {
    TokenStorageRepository? tokenStorageRepository,
  }) : super(ProvideEmailInitial()) {
    on<ProvideEmailSubmitted>((event, emit) async {
      emit(ProvideEmailLoading());
      try {
        final response = await authRepository.provideEmail(event.request);

        if (tokenStorageRepository != null) {
          fetchTokenTaskCallback(tokenStorageRepository);
        } else {
          fetchTokenTaskCallback();
        }

        emit(ProvideEmailSuccess(response));
      } on ApiException catch (error) {
        emit(ProvideEmailFailure(error));
      }
    });
  }
}
