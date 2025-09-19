import 'package:flutter/material.dart';
import 'package:frontend/models/submitting_status.dart';
import 'package:frontend/models/user_details/macros.dart';
import 'package:frontend/models/user_details/predicted_calories.dart';
import 'package:uuid/uuid.dart';

class MacrosChangeState {
  final String? uuid;
  final Macros? macros;
  final PredictedCalories? predictedCalories;
  final int? errorCode;
  final String Function(BuildContext)? getMessage;
  ProcessingStatus? processingStatus;

  MacrosChangeState({
    this.uuid,
    this.macros,
    this.predictedCalories,
    this.errorCode,
    this.getMessage,
    this.processingStatus = ProcessingStatus.emptyProcessingStatus,
  });

  MacrosChangeState copyWith({
    String? uuid,
    Macros? macros,
    PredictedCalories? predictedCalories,
    int? errorCode,
    String Function(BuildContext)? getMessage,
    ProcessingStatus? processingStatus,
  }) {
    return MacrosChangeState(
      uuid: uuid ?? Uuid().v4(),
      macros: macros ?? this.macros,
      predictedCalories: predictedCalories ?? this.predictedCalories,
      errorCode: errorCode ?? this.errorCode,
      getMessage: getMessage ?? this.getMessage,
      processingStatus: processingStatus ?? this.processingStatus,
    );
  }
}
