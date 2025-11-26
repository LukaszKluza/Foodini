import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/events/user_details/user_statistics_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/processing_status.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/repository/user_details/user_details_repository.dart';
import 'package:frontend/states/user_statistics_states.dart';
import 'package:frontend/utils/exception_converter.dart';

class UserStatisticsBloc extends Bloc<UserStatisticsEvent, UserStatisticsState> {
  final UserDetailsRepository userDetailsRepository;

  UserStatisticsBloc(this.userDetailsRepository)
      : super(const UserStatisticsState()) {
    on<LoadUserStatistics>(_onLoad);
    on<RefreshUserStatistics>(_onLoad);
    on<ResetUserStatistics>((event, emit) => emit(const UserStatisticsState()));
  }

  Future<void> _onLoad(
    UserStatisticsEvent event,
    Emitter<UserStatisticsState> emit,
  ) async {
    emit(state.copyWith(processingStatus: ProcessingStatus.gettingOnGoing));
    try {
      final userId = UserStorage().getUserId!;
      final stats = await userDetailsRepository.getUserStatistics(userId);
      emit(
        state.copyWith(
          statistics: stats,
          processingStatus: ProcessingStatus.gettingSuccess,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          processingStatus: ProcessingStatus.gettingFailure,
          errorCode: error.statusCode,
          getMessage: (context) {
            final message = ExceptionConverter.formatErrorMessage(error.data, context);
            return message == 'Unknown error'
                ? AppLocalizations.of(context)!.unknownError
                : message;
          },
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          processingStatus: ProcessingStatus.gettingFailure,
          getMessage: (context) => e.toString(),
        ),
      );
    }
  }
}
