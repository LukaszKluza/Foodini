import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repository/token_storage_repository.dart';

import '../api_exception.dart';
import '../repository/auth_repository.dart';
import '../events/change_password_events.dart';
import '../states/change_password_sates.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final AuthRepository authRepository;
  final TokenStorageRepository tokenStorage;

  ChangePasswordBloc(this.authRepository, this.tokenStorage)
    : super(ChangePasswordInitial()) {
    on<ChangePasswordSubmitted>((event, emit) async {
      emit(ChangePasswordLoading());
      try {
        final response = await authRepository.changePassword(event.request);

        await tokenStorage.deleteAccessToken();
        await tokenStorage.deleteRefreshToken();

        emit(ChangePasswordSuccess(response));
      } on ApiException catch (error) {
        emit(ChangePasswordFailure(error));
      }
    });
  }
}
