import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/events/profile_details_events.dart';
import 'package:frontend/states/profile_details_states.dart';

class ProfileDetailsBlock
    extends Bloc<ProfileDetailsEvent, ProfileDetailsState> {
  ProfileDetailsBlock() : super(ProfileDetailsInitial());
}
