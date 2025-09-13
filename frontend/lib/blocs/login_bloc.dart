import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/events/login_events.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/repository/user_storage.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/login_states.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;
  final TokenStorageRepository tokenStorageRepository;

  LoginBloc(this.authRepository, this.tokenStorageRepository)
    : super(LoginInitial()) {
    on<InitFromUrl>((event, emit) {
      if (event.status == 'success') {
        emit(AccountSuccessVerification(AppConfig.accountActivatedSuccessfully));
      } else if (event.status == 'error') {
        emit(AccountNotVerified());
      }
    });

    on<LoginSubmitted>((event, emit) async {
      emit(ActionInProgress());
      try {
        final response = await authRepository.login(event.request);
        final accessToken = response.accessToken;
        final refreshToken = response.refreshToken;

        tokenStorageRepository.saveAccessToken(accessToken);
        tokenStorageRepository.saveRefreshToken(refreshToken);

        final user = await authRepository.getUser();
        UserStorage().setUser(user);

        emit(LoginSuccess(AppConfig.successfullyLoggedIn));
      } on ApiException catch (error) {
        if (error.data?["detail"] == "EMAIL_NOT_VERIFIED") {
          emit(AccountNotVerified());
          return;
        }
        emit(LoginFailure(error));
      }
    });

    on<ResendVerificationEmail>((event, emit) async {
      try {
        emit(ActionInProgress());
        await authRepository.resendVerificationMail(event.email);

        emit(ResendAccountVerificationSuccess(AppConfig.successfullyResendEmailVerification));
      } on ApiException catch (error) {
        emit(LoginFailure(error));
      }
    });
  }
}
