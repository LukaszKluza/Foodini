import 'package:frontend/models/user_details/user_weight_history.dart';

abstract class UserStatisticsEvent {}

class LoadUserStatistics extends UserStatisticsEvent {}

class RefreshUserStatistics extends UserStatisticsEvent {}

class ResetUserStatistics extends UserStatisticsEvent {}

class LoadUserWeightForDay extends UserStatisticsEvent {
  final DateTime date;
  LoadUserWeightForDay(this.date);
}

class LoadUserWeightHistory extends UserStatisticsEvent {
  final DateTime start;
  final DateTime end;
  LoadUserWeightHistory(this.start, this.end);
}

class UpdateUserWeight extends UserStatisticsEvent {
  final UserWeightHistory entry;
  UpdateUserWeight(this.entry);
}