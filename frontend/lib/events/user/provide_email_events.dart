import 'package:frontend/models/user/provide_email_request.dart';

abstract class ProvideEmailEvent {}

class ProvideEmailSubmitted extends ProvideEmailEvent {
  final ProvideEmailRequest request;

  ProvideEmailSubmitted(this.request);
}
