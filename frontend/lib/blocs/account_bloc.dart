import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/account_events.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/repository/token_storage_repository.dart';
import 'package:frontend/states/account_states.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AuthRepository authRepository;
  final TokenStorageRepository tokenStorageRepository;

  AccountBloc(this.authRepository, this.tokenStorageRepository) : super(AccountInitial()) {
    on<AccountLogoutRequested>((event, emit) async {
      emit(AccountLoggingOut());
      try {
        await authRepository.logout();
        await tokenStorageRepository.deleteAccessToken();
        await tokenStorageRepository.deleteRefreshToken();

        emit(AccountLogoutSuccess());
      } on ApiException catch (error) {
        emit(AccountLogoutFailure(error));
      }
    });
  }
}
