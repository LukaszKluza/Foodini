import 'package:flutter/material.dart';
import 'package:frontend/api_exception.dart';

abstract class MacrosChangeState {}

class MacrosChangeSubmit extends MacrosChangeState {
  final int? protein;
  final int? fat;
  final int? carbs;

  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  MacrosChangeSubmit({
    this.protein,
    this.fat,
    this.carbs,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  MacrosChangeState copyWith({
    int? protein,
    int? fat,
    int? carbs,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return MacrosChangeSubmit(
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }

  factory MacrosChangeSubmit.initial() {
    return MacrosChangeSubmit(
      protein: null,
      fat: null,
      carbs: null,
      isSubmitting: false,
      isSuccess: false,
      errorMessage: null,
    );
  }
}

class MacrosChangeSubmitSuccess extends MacrosChangeState {}

class MacrosChangeSubmitFailure extends MacrosChangeState {
  final String Function(BuildContext)? getMessage;
  final ApiException? error;

  MacrosChangeSubmitFailure({this.getMessage, this.error});
}
