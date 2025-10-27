import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/user/provide_email_events.dart';
import 'package:frontend/fetch_token_task_callback.dart';
import 'package:frontend/repository/api_client.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/provide_email_states.dart';

class ProvideEmailBloc extends Bloc<ProvideEmailEvent?, ProvideEmailState> {
  final UserRepository authRepository;

  ProvideEmailBloc(
    this.authRepository, {
      ApiClient? apiClient,
      TokenStorageService? tokenStorageService,
  }) : super(ProvideEmailInitial()) {
    on<ProvideEmailSubmitted>((event, emit) async {
      emit(ProvideEmailLoading());
      try {
        final response = await authRepository.provideEmail(event.request);

        await fetchTokenTaskCallback(apiClientWithCache: apiClient, tokenStorage: tokenStorageService);

        emit(ProvideEmailSuccess(response));
      } on ApiException catch (error) {
        emit(ProvideEmailFailure(error));
      }
    });
  }
}
