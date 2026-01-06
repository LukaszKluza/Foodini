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
import 'package:frontend/views/widgets/title_text.dart';
import 'package:frontend/views/widgets/user_details/missing_predictions_alert.dart';
import 'package:go_router/go_router.dart';

class PredictionResultsScreen extends StatelessWidget {
  const PredictionResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
          child: Scaffold(
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
          ),
        ),
      )
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

  double _calculateCalories() {
    final protein = double.tryParse(_proteinController.text) ?? 0.0;
    final fat = double.tryParse(_fatController.text) ?? 0.0;
    final carbs = double.tryParse(_carbsController.text) ?? 0.0;

    return (protein * Constants.proteinEstimator) +
        (fat * Constants.fatEstimator) +
        (carbs * Constants.carbsEstimator);
  }

  String? _macrosValidator(String? value, int target) {
    final total = _calculateCalories();
    const tolerance = 30.0;

    if ((total - target).abs() > tolerance) {
      return '${AppLocalizations.of(context)!.macros} = '
          '${total.round()} ${AppLocalizations.of(context)!.kcal}, '
          '${AppLocalizations.of(context)!.expected} ~ '
          '$target ${AppLocalizations.of(context)!.kcal}';
    }
    return null;
  }

  Widget _buildMacroField(
      String label,
      TextEditingController controller,
      int target,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orange.shade200, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16)
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
      padding: const EdgeInsets.fromLTRB(35, 16, 35, 16),
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
                    MissingPredictionsAlert(message: AppLocalizations.of(context)!.fillFormToSeePredictions,)
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
    final data = state.predictedCalories!;
    _proteinController.text = data.predictedMacros.protein.toStringAsFixed(1);
    _fatController.text = data.predictedMacros.fat.toStringAsFixed(1);
    _carbsController.text = data.predictedMacros.carbs.toStringAsFixed(1);

    return [
      _buildSummaryCard(
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.predictedCalories.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withAlpha(230),
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${data.targetCalories} ${AppLocalizations.of(context)!.kcal}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      if (data.dietDurationDays != null && data.dietDurationDays! > 0) ...[
        const SizedBox(height: 8),
        _buildSummaryCard(
          child: Center(
            child: Text(
              '${AppLocalizations.of(context)!.dietDuration}: ${data.dietDurationDays} ${AppLocalizations.of(context)!.days}',
              style: TextStyle(
                color: Colors.white.withAlpha(230),
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
      const SizedBox(height: 20),

      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(
              AppLocalizations.of(context)!.bmr,
              '${data.bmr} ${AppLocalizations.of(context)!.kcal}',
            ),
            const SizedBox(width: 12),
            _buildInfoCard(
              AppLocalizations.of(context)!.tdee,
              '${data.tdee} ${AppLocalizations.of(context)!.kcal}',
            ),
          ],
        ),
      ),
      const SizedBox(height: 30),

      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 16),
        child: Text(
          AppLocalizations.of(context)!.predictedMacros,
          style: TextStyle(
            fontSize: 60.sp.clamp(15.0, 20.0),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),

      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMacroField(AppLocalizations.of(context)!.proteinG, _proteinController, data.targetCalories),
          _buildMacroField(AppLocalizations.of(context)!.fatG, _fatController, data.targetCalories),
          _buildMacroField(AppLocalizations.of(context)!.carbsG, _carbsController, data.targetCalories),
        ],
      ),
      const SizedBox(height: 32),
    ];
  }

  Widget _buildSummaryCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.orange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade100, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(),
            const SizedBox(height: 4),

            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
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
                protein: double.tryParse(_proteinController.text)!,
                fat: double.tryParse(_fatController.text)!,
                carbs: double.tryParse(_carbsController.text)!,
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
}
