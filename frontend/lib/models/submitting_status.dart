enum ProcessingStatus {
  gettingOnGoing,
  submittingOnGoing,
  submittingSuccess,
  gettingSuccess,
  submittingFailure,
  emptyProcessingStatus;

  bool get isOngoing =>
      this == ProcessingStatus.gettingOnGoing ||
      this == ProcessingStatus.submittingOnGoing;

  bool get isFailure => this == ProcessingStatus.submittingFailure;

  bool get isEndOfProcessing =>
      this == ProcessingStatus.submittingSuccess ||
      this == ProcessingStatus.gettingSuccess ||
      this == ProcessingStatus.submittingFailure;
}
