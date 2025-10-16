import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/user/change_password_events.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/change_password_states.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final UserRepository authRepository;
  final TokenStorageService tokenStorage;

  ChangePasswordBloc(this.authRepository, this.tokenStorage)
    : super(ChangePasswordInitial()) {
    on<ChangePasswordSubmitted>((event, emit) async {
      emit(ChangePasswordLoading());
      try {
        await authRepository.changePassword(event.request);

        await tokenStorage.deleteAccessToken();
        await tokenStorage.deleteRefreshToken();

        emit(ChangePasswordSuccess());
      } on ApiException catch (error) {
        emit(ChangePasswordFailure(error));
      }
    });
  }
}
