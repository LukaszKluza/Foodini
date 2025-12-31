import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/processing_status.dart';
import 'package:frontend/models/user_details/user_statistics.dart';
import 'package:frontend/models/user_details/user_weight_history.dart';

class UserStatisticsState extends Equatable {
  final ProcessingStatus processingStatus;
  final UserStatistics? statistics;
  final int? errorCode;
  final String Function(BuildContext)? getMessage;

  final UserWeightHistory? dailyWeight;

  final List<UserWeightHistory> weightHistory;

  const UserStatisticsState({
    this.processingStatus = ProcessingStatus.emptyProcessingStatus,
    this.statistics,
    this.errorCode,
    this.getMessage,
    this.dailyWeight,
    this.weightHistory = const [],
  });

  UserStatisticsState copyWith({
    ProcessingStatus? processingStatus,
    UserStatistics? statistics,
    UserWeightHistory? dailyWeight,
    List<UserWeightHistory>? weightHistory,
    int? errorCode,
    String Function(BuildContext)? getMessage,
  }) {
    return UserStatisticsState(
      processingStatus: processingStatus ?? this.processingStatus,
      statistics: statistics ?? this.statistics,
      dailyWeight: dailyWeight ?? this.dailyWeight,
      weightHistory: weightHistory ?? this.weightHistory,
      errorCode: errorCode ?? this.errorCode,
      getMessage: getMessage ?? this.getMessage,
    );
  }

  @override
  List<Object?> get props => [
    processingStatus,
    statistics,
    errorCode,
    weightHistory,
  ];
}
