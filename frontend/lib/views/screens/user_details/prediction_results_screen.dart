import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/blocs/user_details/macros_change_bloc.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user_details/macros_change_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/listeners/user_details/macros_change_listener.dart';
import 'package:frontend/models/user_details/macros.dart';
import 'package:frontend/states/macros_change_states.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:frontend/views/widgets/diet_generation/action_buttons.dart';
import 'package:frontend/views/widgets/missing_predictions_alert.dart';
import 'package:frontend/views/widgets/title_text.dart';
import 'package:go_router/go_router.dart';

class PredictionResultsScreen extends StatelessWidget {
  const PredictionResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: TitleTextWidgets.scaledTitle(
            AppLocalizations.of(context)!.caloriesPrediction,
            longText: true,
          ),
        ),
      ),
      body: _PredictionResultsForm(),
      bottomNavigationBar: BottomNavBar(
        currentRoute: GoRouterState.of(context).uri.path,
        mode: NavBarMode.wizard,
      ),
    );
  }
}

class _PredictionResultsForm extends StatefulWidget {
  @override
  State<_PredictionResultsForm> createState() => _PredictionResultsFormState();
}

class _PredictionResultsFormState extends State<_PredictionResultsForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _proteinController = TextEditingController();
  late final TextEditingController _fatController = TextEditingController();
  late final TextEditingController _carbsController = TextEditingController();

  String? _message;
  int? _errorCode;
  TextStyle _messageStyle = Styles.errorStyle;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<MacrosChangeBloc>();
    bloc.add(LoadInitialMacros());
  }

  @override
  void dispose() {
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  int _calculateCalories() {
    final protein = int.tryParse(_proteinController.text) ?? 0;
    final fat = int.tryParse(_fatController.text) ?? 0;
    final carbs = int.tryParse(_carbsController.text) ?? 0;
    return (protein * Constants.proteinEstimator) +
        (fat * Constants.fatEstimator) +
        (carbs * Constants.carbsEstimator);
  }

  String? _macrosValidator(String? value, int target) {
    final total = _calculateCalories();
    const tolerance = 30;

    if ((total - target).abs() > tolerance) {
      return '${AppLocalizations.of(context)!.macros} = $total ${AppLocalizations.of(context)!.kcal}, ${AppLocalizations.of(context)!.expected} ~ $target ${AppLocalizations.of(context)!.kcal}';
    }
    return null;
  }

  Widget _buildMacroField(
    String label,
    TextEditingController controller,
    int target,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          validator: (value) => _macrosValidator(value, target),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(35.0),
      child: BlocConsumer<MacrosChangeBloc, MacrosChangeState>(
        listener: (context, state) {
          MacrosChangeListenerHelper.onMacrosChangeSubmitListener(
            context: context,
            state: state,
            mounted: mounted,
            setMessage: (msg) => setState(() => _message = msg),
            setErrorCode: (code) => setState(() => _errorCode = code),
            setMessageStyle: (style) => setState(() => _messageStyle = style),
          );
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                if (state.processingStatus!.isOngoing)
                  const Center(child: CircularProgressIndicator()),
                if (state.processingStatus!.isSuccess) ...[
                  ...caloriesPredictionProperties(context, state),
                  submitButton(context),
                ],
                if (state.processingStatus!.isFailure) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.warning_amber,
                      color: Colors.red,
                      size: 200.0,
                    ),
                  ),
                  if (_errorCode == 404) ...[
                    const MissingPredictionsAlert()
                  ] else
                    retryRequestButton(context),
                ],
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _message!,
                      style: _messageStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> caloriesPredictionProperties(
    BuildContext context,
    MacrosChangeState state,
  ) {
    final targetCalories = state.predictedCalories!.targetCalories;
    final bmr = state.predictedCalories!.bmr;
    final tdee = state.predictedCalories!.tdee;
    final dietDurationDays = state.predictedCalories!.dietDurationDays;
    final target = state.predictedCalories!.targetCalories;
    _proteinController.text =
        state.predictedCalories!.predictedMacros.protein.toString();
    _fatController.text =
        state.predictedCalories!.predictedMacros.fat.toString();
    _carbsController.text =
        state.predictedCalories!.predictedMacros.carbs.toString();

    Widget buildField(String label, String value) =>
        Center(child: Text('$label: $value', textAlign: TextAlign.center));

    List<Widget> fields = [
      buildField(
        AppLocalizations.of(context)!.predictedCalories,
        '$targetCalories ${AppLocalizations.of(context)!.kcal}',
      ),
      const SizedBox(height: 16),
      buildField(
        AppLocalizations.of(context)!.bmr,
        '$bmr ${AppLocalizations.of(context)!.kcal}',
      ),
      const SizedBox(height: 16),
      buildField(
        AppLocalizations.of(context)!.tdee,
        '$tdee ${AppLocalizations.of(context)!.kcal}',
      ),
    ];

    if (dietDurationDays != null && dietDurationDays > 0) {
      fields.add(const SizedBox(height: 16));
      fields.add(
        buildField(
          AppLocalizations.of(context)!.dietDuration,
          '$dietDurationDays ${AppLocalizations.of(context)!.days}',
        ),
      );
    }

    fields.addAll([
      const SizedBox(height: 16),
      Center(
        child: Text(
          AppLocalizations.of(context)!.predictedMacros,
          style: TextStyle(
            fontSize: 60.sp.clamp(15.0, 20.0),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 8),
      Center(
        child: _buildMacroField(
          AppLocalizations.of(context)!.proteinG,
          _proteinController,
          target,
        ),
      ),
      Center(
        child: _buildMacroField(
          AppLocalizations.of(context)!.fatG,
          _fatController,
          target,
        ),
      ),
      Center(
        child: _buildMacroField(
          AppLocalizations.of(context)!.carbsG,
          _carbsController,
          target,
        ),
      ),
    ]);

    return fields;
  }

  Center submitButton(BuildContext context) {
    return customSubmitButton(
      Key('save_predicted_calories_button'),
      () {
        _message = null;
        _errorCode = null;

        if (_formKey.currentState!.validate()) {
          context.read<MacrosChangeBloc>().add(
            SubmitMacrosChange(
              Macros(
                protein: int.tryParse(_proteinController.text)!,
                fat: int.tryParse(_fatController.text)!,
                carbs: int.tryParse(_carbsController.text)!,
              ),
            ),
          );
        }
      },
      Text(AppLocalizations.of(context)!.savePredictedCalories),
    );
  }

  Center retryRequestButton(BuildContext context) {
    return customRetryButton(
      Key('refresh_request_button'),
      () {
        _message = null;
        _errorCode = null;

        context.read<MacrosChangeBloc>().add(LoadInitialMacros());
      },
      Text(AppLocalizations.of(context)!.refreshRequest),
    );
  }

  Center redirectToProfileDetailsButton(BuildContext context) {
    return customRedirectButton(
      Key('redirect_to_profile_details_button'),
      () {
        _message = null;
        _errorCode = null;

        context.go('/profile-details');
      },
      Text(AppLocalizations.of(context)!.redirectToProfileDetails),
    );
  }
}
