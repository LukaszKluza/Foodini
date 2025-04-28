import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/login_events.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/repository/user_storage.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:frontend/states/login_states.dart';

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

        UserStorage().setUser(response);
        tokenStorageRepository.saveAccessToken(accessToken);
        tokenStorageRepository.saveRefreshToken(refreshToken);

        emit(LoginSuccess(response));
      } on ApiException catch (error) {
        emit(LoginFailure(error));
      }
    });
  }
}
