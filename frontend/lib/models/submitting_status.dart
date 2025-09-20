enum ProcessingStatus {
  gettingOnGoing,
  submittingOnGoing,
  submittingSuccess,
  gettingSuccess,
  submittingFailure,
  gettingFailure,
  emptyProcessingStatus;

  bool get isOngoing =>
      this == ProcessingStatus.gettingOnGoing ||
      this == ProcessingStatus.submittingOnGoing;

  bool get isSuccess =>
      this == ProcessingStatus.submittingSuccess ||
      this == ProcessingStatus.gettingSuccess;

  bool get isFailure =>
      this == ProcessingStatus.submittingFailure ||
      this == ProcessingStatus.gettingFailure;

  bool get isEndOfProcessing => isFailure || isSuccess;
}
