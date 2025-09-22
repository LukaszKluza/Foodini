import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/submitting_status.dart';
import 'package:frontend/models/user_details/macros.dart';
import 'package:frontend/models/user_details/predicted_calories.dart';

class MacrosChangeState extends Equatable{
  final Macros? macros;
  final PredictedCalories? predictedCalories;
  final int? errorCode;
  final String Function(BuildContext)? getMessage;
  final ProcessingStatus? processingStatus;

  const MacrosChangeState({
    this.macros,
    this.predictedCalories,
    this.errorCode,
    this.getMessage,
    this.processingStatus = ProcessingStatus.emptyProcessingStatus,
  });

  MacrosChangeState copyWith({
    Macros? macros,
    PredictedCalories? predictedCalories,
    int? errorCode,
    String Function(BuildContext)? getMessage,
    ProcessingStatus? processingStatus,
  }) {
    return MacrosChangeState(
      macros: macros ?? this.macros,
      predictedCalories: predictedCalories ?? this.predictedCalories,
      errorCode: errorCode ?? this.errorCode,
      getMessage: getMessage ?? this.getMessage,
      processingStatus: processingStatus ?? this.processingStatus,
    );
  }

  @override
  String toString() {
    return 'MacrosChangeState(macros: $macros, predictedCalories: $predictedCalories, '
        'errorCode: $errorCode, processingStatus: $processingStatus)';
  }

  @override
  List<Object?> get props => [macros, predictedCalories, errorCode, processingStatus];
}
