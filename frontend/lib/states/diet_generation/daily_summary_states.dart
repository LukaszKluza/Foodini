import 'package:frontend/api_exception.dart';
import 'package:frontend/models/diet_generation/daily_summary.dart';
import 'package:frontend/models/processing_status.dart';

class DailySummaryState {
  final DailySummary? dailySummary;
  final ProcessingStatus gettingDailySummaryStatus;
  final ProcessingStatus changingMealStatus;
  final ProcessingStatus updatingMeal;
  final DietGeneratingInfo dietGeneratingInfo;

  DailySummaryState({
    this.dailySummary,
    this.gettingDailySummaryStatus = ProcessingStatus.emptyProcessingStatus,
    this.changingMealStatus = ProcessingStatus.emptyProcessingStatus,
    this.updatingMeal = ProcessingStatus.emptyProcessingStatus,
    this.dietGeneratingInfo = const DietGeneratingInfo(),
  });

  DailySummaryState copyWith({
    DailySummary? dailySummary,
    ProcessingStatus? gettingDailySummaryStatus,
    ProcessingStatus? changingMealStatus,
    ProcessingStatus? updatingMeal,

    DateTime? day,
    ProcessingStatus? processingStatus,
  }) {
    return DailySummaryState(
      dailySummary: dailySummary ?? this.dailySummary,
      gettingDailySummaryStatus: gettingDailySummaryStatus ?? this.gettingDailySummaryStatus,
      changingMealStatus: gettingDailySummaryStatus ?? this.gettingDailySummaryStatus,
      updatingMeal: gettingDailySummaryStatus ?? this.gettingDailySummaryStatus,
      dietGeneratingInfo: dietGeneratingInfo.copyWith(day: day, processingStatus: processingStatus),
    );
  }

  @override
  String toString() {
    return 'DailySummaryState('
        'dailySummary: $dailySummary, '
        'gettingDailySummaryStatus: $gettingDailySummaryStatus, '
        'changingMealStatus: $changingMealStatus, '
        'updatingMeal: $updatingMeal, '
        'dietGeneratingInfo: ${dietGeneratingInfo.toString()}'
        ')';
  }

}

class DailySummaryError {
  final String? message;
  final ApiException? error;

  DailySummaryError({this.message, this.error});
}

class DailySummaryUpdateSuccess{
  final DailySummary updatedSummary;
  final String? successMessage;

  DailySummaryUpdateSuccess({
    required this.updatedSummary,
    this.successMessage,
  });
}

class DailySummaryUpdateFailure{
  final DailySummary previousSummary;
  final String? errorMessage;
  final ApiException? error;

  DailySummaryUpdateFailure({
    required this.previousSummary,
    this.errorMessage,
    this.error,
  });
}

class DietGeneratingInfo {
  final DateTime? day;
  final ProcessingStatus processingStatus;

  const DietGeneratingInfo({
    this.day,
    this.processingStatus = ProcessingStatus.emptyProcessingStatus,
  });

  DietGeneratingInfo copyWith({
    DateTime? day,
    ProcessingStatus? processingStatus,
  }) {
    return DietGeneratingInfo(
      day: day ?? this.day,
      processingStatus: processingStatus ?? this.processingStatus,
    );
  }

  @override
  String toString() {
    return 'DietGeneratingInfo(day: $day, processingStatus: $processingStatus)';
  }
}
