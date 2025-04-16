import 'package:flutter_bloc/flutter_bloc.dart';

import '../api_exception.dart';
import '../events/login_events.dart';
import '../repository/auth_repository.dart';
import '../repository/token_storage_repository.dart';
import '../states/login_states.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;
  final TokenStorageRepository tokenStorageRepository;

  LoginBloc(this.authRepository, this.tokenStorageRepository)
    : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      try {
        final response = await authRepository.login(event.request);
        final accessToken = response.accessToken;
        final refreshToken = response.refreshToken;

        tokenStorageRepository.saveAccessToken(accessToken);
        tokenStorageRepository.saveRefreshToken(refreshToken);

        emit(LoginSuccess(response));
      } on ApiException catch (error) {
        emit(LoginFailure(error));
      }
    });
  }
}
