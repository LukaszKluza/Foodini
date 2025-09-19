import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user_details/macros_change_bloc.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user_details/macros_change_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/listeners/user_details/macros_change_listener.dart';
import 'package:frontend/models/user_details/macros.dart';
import 'package:frontend/states/macros_change_states.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

class PredictionResultsScreen extends StatelessWidget {
  const PredictionResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.caloriesPrediction,
            style: Styles.titleStyle,
          ),
        ),
      ),
      body: _PredictionResultsForm(),
      bottomNavigationBar: BottomNavBar(
        currentRoute: GoRouterState.of(context).uri.path,
        mode: NavBarMode.wizard,
        prevRoute: '/calories-prediction',
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
  late final TextEditingController _dietDurationController =
      TextEditingController();

  String? _message;
  int? _errorCode;
  TextStyle _messageStyle = Styles.errorStyle;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<MacrosChangeBloc>();
    bloc.add(RefreshMacrosBloc());
  }

  @override
  void dispose() {
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    _dietDurationController.dispose();
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
        // listenWhen:
        //     (prev, curr) => prev.submittingStatus != curr.submittingStatus,
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
                if (state.processingStatus!.isFailure)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.warning_amber,
                      color: Colors.red,
                      size: 200.0,
                    ),
                  )
                else if (state.predictedCalories != null)
                  ...caloriesPredictionProperties(context, state),
                if (state.processingStatus!.isOngoing)
                  const Center(child: CircularProgressIndicator()),
                if (state.predictedCalories != null) submitButton(context),
                if (_message != null) ...[
                  if (_errorCode == 404)
                    redirectToProfileDetailsButton(context)
                  else if (_errorCode != null)
                    retryRequestButton(context),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _message!,
                      style: _messageStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
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

    if (dietDurationDays != null) {
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
          style: Styles.titleStyle,
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

  Center basicButton(
    BuildContext context,
    Key buttonKey,
    VoidCallback? onPressed,
    ButtonStyle buttonStyle,
    Widget? buttonChild,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: ElevatedButton(
          key: buttonKey,
          onPressed: onPressed,
          style: buttonStyle,
          child: buttonChild,
        ),
      ),
    );
  }

  Center submitButton(BuildContext context) {
    return basicButton(
      context,
      Key('save_predicted_calories_button'),
      () {
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
      ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB2F2BB),
        minimumSize: const Size.fromHeight(48),
      ),
      Text(AppLocalizations.of(context)!.savePredictedCalories),
    );
  }

  Center retryRequestButton(BuildContext context) {
    return basicButton(
      context,
      Key('refresh_request_button'),
      () => context.read<MacrosChangeBloc>().add(LoadInitialMacros()),
      ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDD9E74),
        minimumSize: const Size.fromHeight(48),
      ),
      Text('Refresh'),
    );
  }

  Center redirectToProfileDetailsButton(BuildContext context) {
    return basicButton(
      context,
      Key('redirect_to_profile_details_button'),
      () => context.go('/profile-details'),
      ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF2D8B2),
        minimumSize: const Size.fromHeight(48),
      ),
      Text('redirectToProfileDetailsButton'),
    );
  }
}
