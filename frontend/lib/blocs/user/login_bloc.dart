import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/user/login_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/login_states.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository authRepository;
  final TokenStorageService tokenStorageService;

  LoginBloc(this.authRepository, this.tokenStorageService)
    : super(LoginInitial()) {
    on<InitFromUrl>((event, emit) {
      if (event.status == 'success') {
        emit(
          AccountSuccessVerification(
            (context) =>
                AppLocalizations.of(context)!.accountActivatedSuccessfully,
          ),
        );
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

        tokenStorageService.saveAccessToken(accessToken);
        tokenStorageService.saveRefreshToken(refreshToken);

        final user = await authRepository.getUser(response.id);
        UserStorage().setUser(user);

        emit(
          LoginSuccess(
            userResponse: user,
            getMessage:
                (context) => AppLocalizations.of(context)!.successfullyLoggedIn,
          ),
        );
      } on ApiException catch (error) {
        if (error.data?['detail'] == 'EMAIL_NOT_VERIFIED') {
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

        emit(
          ResendAccountVerificationSuccess(
            (context) =>
                AppLocalizations.of(
                  context,
                )!.successfullyResendEmailVerification,
          ),
        );
      } on ApiException catch (error) {
        emit(LoginFailure(error));
      }
    });
  }
}
