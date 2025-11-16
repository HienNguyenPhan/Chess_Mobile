enum StatusEnum {
  initial,
  inProgress,
  success,
  failure,
}

extension StatusEnumX on StatusEnum {
  bool get isInitial => this == StatusEnum.initial;
  bool get isInProgress => this == StatusEnum.inProgress;
  bool get isSuccess => this == StatusEnum.success;
  bool get isFailure => this == StatusEnum.failure;
}
