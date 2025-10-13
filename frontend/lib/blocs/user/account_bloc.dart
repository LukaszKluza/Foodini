import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/user/account_events.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/account_states.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final UserRepository authRepository;
  final TokenStorageRepository tokenStorageRepository;

  AccountBloc(this.authRepository, this.tokenStorageRepository)
    : super(AccountInitial()) {
    on<AccountLogoutRequested>((event, emit) async {
      emit(AccountActionInProgress());
      try {
        if (UserStorage().getUserId != null) {
          await authRepository.logout(UserStorage().getUserId!);
          UserStorage().removeUser();
        }
        await tokenStorageRepository.deleteAccessToken();

        emit(AccountLogoutSuccess());
      } on ApiException catch (error) {
        emit(AccountFailure(error));
      }
    });

    on<AccountChangeLanguageRequested>((event, emit) async {
      emit(AccountActionInProgress());
      try {
        var userId = UserStorage().getUserId;

        if (userId != null) {
          await authRepository.changeLanguage(event.request, userId);
        }

        emit(AccountChangeLanguageSuccess(event.request.language));
      } on ApiException catch (error) {
        emit(AccountFailure(error));
      }
    });

    on<AccountDeleteRequested>((event, emit) async {
      emit(AccountActionInProgress());
      try {
        final userId = UserStorage().getUserId;
        if (userId == null) {
          emit(AccountFailure(ApiException('Unknown error')));
        }
        await authRepository.delete(UserStorage().getUserId!);
        UserStorage().removeUser();
        await tokenStorageRepository.deleteAccessToken();

        emit(AccountDeleteSuccess());
      } on ApiException catch (error) {
        emit(AccountFailure(error));
      }
    });
  }
}
