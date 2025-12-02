import 'package:frontend/models/user_details/user_weight_history.dart';

abstract class UserStatisticsEvent {}

class LoadUserStatistics extends UserStatisticsEvent {}

class RefreshUserStatistics extends UserStatisticsEvent {}

class ResetUserStatistics extends UserStatisticsEvent {}

class UpdateUserWeight extends UserStatisticsEvent {
  final UserWeightHistory entry;
  UpdateUserWeight(this.entry);
}