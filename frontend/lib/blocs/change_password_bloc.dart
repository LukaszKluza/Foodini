import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/events/change_password_events.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/change_password_states.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final AuthRepository authRepository;
  final TokenStorageRepository tokenStorage;

  ChangePasswordBloc(this.authRepository, this.tokenStorage)
    : super(ChangePasswordInitial()) {
    on<ChangePasswordSubmitted>((event, emit) async {
      emit(ChangePasswordLoading());
      try {
        await authRepository.changePassword(event.request);

        await tokenStorage.deleteAccessToken();
        await tokenStorage.deleteRefreshToken();

        emit(ChangePasswordSuccess(AppConfig.passwordSuccessfullyChanged));
      } on ApiException catch (error) {
        emit(ChangePasswordFailure(error));
      }
    });

  }
}
