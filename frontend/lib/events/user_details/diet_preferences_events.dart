abstract class DietPreferencesEvents {}

class DietPreferencesSubmitted extends DietPreferencesEvents {
  final DietPreferencesSubmitted request;

  DietPreferencesSubmitted(this.request);
}
