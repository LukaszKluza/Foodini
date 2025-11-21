import 'package:flutter/cupertino.dart';
import 'package:frontend/models/diet_generation/daily_summary.dart';
import 'package:frontend/models/processing_status.dart';
import 'package:frontend/utils/diet_generation/meals_generation_notification.dart';

class DailySummaryState {
  final DailySummary? dailySummary;
  final ProcessingStatus gettingDailySummaryStatus;
  final ProcessingStatus changingMealStatus;
  final ProcessingStatus updatingMealStatus;
  final DietGeneratingInfo dietGeneratingInfo;
  final int? errorCode;
  final String Function(BuildContext)? getMessage;
  final MealsGenerationNotification Function(BuildContext)? getNotification;

  DailySummaryState({
    this.dailySummary,
    this.gettingDailySummaryStatus = ProcessingStatus.emptyProcessingStatus,
    this.changingMealStatus = ProcessingStatus.emptyProcessingStatus,
    this.updatingMealStatus = ProcessingStatus.emptyProcessingStatus,
    this.dietGeneratingInfo = const DietGeneratingInfo(),
    this.errorCode,
    this.getMessage,
    this.getNotification,
  });

  DailySummaryState copyWith({
    DailySummary? dailySummary,
    ProcessingStatus? gettingDailySummaryStatus,
    ProcessingStatus? changingMealStatus,
    ProcessingStatus? updatingMealStatus,

    DateTime? day,
    ProcessingStatus? processingStatus,

    int? errorCode,
    String Function(BuildContext)? getMessage,
    MealsGenerationNotification Function(BuildContext)? getNotification,
  }) {
    return DailySummaryState(
      dailySummary: dailySummary ?? this.dailySummary,
      gettingDailySummaryStatus: gettingDailySummaryStatus ?? this.gettingDailySummaryStatus,
      changingMealStatus: changingMealStatus ?? this.changingMealStatus,
      updatingMealStatus: updatingMealStatus ?? this.updatingMealStatus,
      dietGeneratingInfo: processingStatus == null && day == null ? dietGeneratingInfo : dietGeneratingInfo.copyWith(day: day, processingStatus: processingStatus),
      errorCode: errorCode ?? this.errorCode,
      getMessage: getMessage ?? this.getMessage,
      getNotification: getNotification ?? this.getNotification,
    );
  }

  @override
  String toString() {
    return 'DailySummaryState('
        'dailySummary: $dailySummary, '
        'gettingDailySummaryStatus: $gettingDailySummaryStatus, '
        'changingMealStatus: $changingMealStatus, '
        'updatingMeal: $updatingMealStatus, '
        'dietGeneratingInfo: ${dietGeneratingInfo.toString()}'
        'errorCode: $errorCode'
        ')';
  }
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
