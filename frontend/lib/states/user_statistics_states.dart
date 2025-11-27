import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/processing_status.dart';
import 'package:frontend/models/user_details/user_statistics.dart';

class UserStatisticsState extends Equatable {
  final ProcessingStatus processingStatus;
  final UserStatistics? statistics;
  final int? errorCode;
  final String Function(BuildContext)? getMessage;

  const UserStatisticsState({
    this.processingStatus = ProcessingStatus.emptyProcessingStatus,
    this.statistics,
    this.errorCode,
    this.getMessage,
  });

  UserStatisticsState copyWith({
    ProcessingStatus? processingStatus,
    UserStatistics? statistics,
    int? errorCode,
    String Function(BuildContext)? getMessage,
  }) {
    return UserStatisticsState(
      processingStatus: processingStatus ?? this.processingStatus,
      statistics: statistics ?? this.statistics,
      errorCode: errorCode ?? this.errorCode,
      getMessage: getMessage ?? this.getMessage,
    );
  }

  @override
  List<Object?> get props => [processingStatus, statistics, errorCode];
}
