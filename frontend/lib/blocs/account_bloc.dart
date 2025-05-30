import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/account_events.dart';
import 'package:frontend/repository/user_repository.dart';
import 'package:frontend/repository/user_storage.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/account_states.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AuthRepository authRepository;
  final TokenStorageRepository tokenStorageRepository;

  AccountBloc(this.authRepository, this.tokenStorageRepository) : super(AccountInitial()) {
    on<AccountLogoutRequested>((event, emit) async {
      emit(AccountActionInProgress());
      try {
        var userId = UserStorage().getUserId!;
        await authRepository.logout(userId);
        UserStorage().removeUser();
        await tokenStorageRepository.deleteAccessToken();
        await tokenStorageRepository.deleteRefreshToken();

        emit(AccountLogoutSuccess());
      } on ApiException catch (error) {
        emit(AccountFailure(error));
      }
    });

    on<AccountChangeLanguageRequested>((event, emit) async {
      emit(AccountActionInProgress());
      try {
        var userId = UserStorage().getUserId!;
        await authRepository.changeLanguage(event.request, userId);

        emit(AccountChangeLanguageSuccess(event.request.language));
      } on ApiException catch (error) {
        emit(AccountFailure(error));
      }
    });

    on<AccountDeleteRequested>((event, emit) async {
      emit(AccountActionInProgress());
      try {
        var userId = UserStorage().getUserId!;
        await authRepository.delete(userId);
        UserStorage().removeUser();
        await tokenStorageRepository.deleteAccessToken();
        await tokenStorageRepository.deleteRefreshToken();

        emit(AccountDeleteSuccess());
      } on ApiException catch (error) {
        emit(AccountFailure(error));
      }
    });
  }
}
