import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user_details/macros_change_bloc.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user_details/macros_change_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/listeners/user_details/macros_change_listener.dart';
import 'package:frontend/models/user_details/predicted_calories.dart';
import 'package:frontend/states/macros_change_states.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

class PredictionResultsScreen extends StatelessWidget {
  final PredictedCalories predictedCalories;

  const PredictionResultsScreen({super.key, required this.predictedCalories});

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
      body: _PredictionResultsForm(predictedCalories: predictedCalories),
      bottomNavigationBar: BottomNavBar(
        currentRoute: GoRouterState.of(context).uri.path,
        mode: NavBarMode.wizard,
        prevRoute: '/calories-prediction',
      ),
    );
  }
}

class _PredictionResultsForm extends StatefulWidget {
  final PredictedCalories predictedCalories;

  const _PredictionResultsForm({required this.predictedCalories});

  @override
  State<_PredictionResultsForm> createState() => _PredictionResultsFormState();
}

class _PredictionResultsFormState extends State<_PredictionResultsForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbsController;
  late TextEditingController _dietDurationController;

  String? _message;
  TextStyle _messageStyle = Styles.errorStyle;

  @override
  void initState() {
    super.initState();
    _proteinController = TextEditingController(
      text: widget.predictedCalories.predictedMacros.protein.toString(),
    );
    _fatController = TextEditingController(
      text: widget.predictedCalories.predictedMacros.fat.toString(),
    );
    _carbsController = TextEditingController(
      text: widget.predictedCalories.predictedMacros.carbs.toString(),
    );
    _dietDurationController = TextEditingController(
      text: widget.predictedCalories.dietDurationDays?.toString() ?? '',
    );

    final bloc = context.read<MacrosChangeBloc>();
    bloc.add(UpdateProtein(widget.predictedCalories.predictedMacros.protein));
    bloc.add(UpdateFat(widget.predictedCalories.predictedMacros.fat));
    bloc.add(UpdateCarbs(widget.predictedCalories.predictedMacros.carbs));
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

  String? _macrosValidator(String? value) {
    final total = _calculateCalories();
    final target = widget.predictedCalories.targetCalories;
    const tolerance = 30;

    if ((total - target).abs() > tolerance) {
      return '${AppLocalizations.of(context)!.macros} = $total ${AppLocalizations.of(context)!.kcal}, ${AppLocalizations.of(context)!.expected} ~ $target ${AppLocalizations.of(context)!.kcal}';
    }
    return null;
  }

  Widget _buildMacroField(
    String label,
    TextEditingController controller,
    void Function(String) onChanged,
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
          validator: _macrosValidator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetCalories = widget.predictedCalories.targetCalories;
    final bmr = widget.predictedCalories.bmr;
    final tdee = widget.predictedCalories.tdee;
    final dietDurationDays = widget.predictedCalories.dietDurationDays;

    final fields = [
      Center(
        child: Text(
          '${AppLocalizations.of(context)!.predictedCalories}: $targetCalories ${AppLocalizations.of(context)!.kcal}',
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 16),
      Center(
        child: Text(
          '${AppLocalizations.of(context)!.bmr}: $bmr ${AppLocalizations.of(context)!.kcal}',
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 16),
      Center(
        child: Text(
          '${AppLocalizations.of(context)!.tdee}: $tdee ${AppLocalizations.of(context)!.kcal}',
          textAlign: TextAlign.center,
        ),
      ),
      if (dietDurationDays != null) ...[
        const SizedBox(height: 16),
        Center(
          child: Text(
            '${AppLocalizations.of(context)!.dietDuration}: $dietDurationDays ${AppLocalizations.of(context)!.days}',
            textAlign: TextAlign.center,
          ),
        ),
      ],
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
          (value) => context.read<MacrosChangeBloc>().add(
            UpdateProtein(int.tryParse(value) ?? 0),
          ),
        ),
      ),
      Center(
        child: _buildMacroField(
          AppLocalizations.of(context)!.fatG,
          _fatController,
          (value) => context.read<MacrosChangeBloc>().add(
            UpdateFat(int.tryParse(value) ?? 0),
          ),
        ),
      ),
      Center(
        child: _buildMacroField(
          AppLocalizations.of(context)!.carbsG,
          _carbsController,
          (value) => context.read<MacrosChangeBloc>().add(
            UpdateCarbs(int.tryParse(value) ?? 0),
          ),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(35.0),
      child: BlocConsumer<MacrosChangeBloc, MacrosChangeState>(
        listener: (context, state) {
          MacrosChangeListenerHelper.onMacrosChangeSubmitListener(
            context: context,
            state: state,
            mounted: mounted,
            setState: setState,
            setMessage: (msg) => setState(() => _message = msg),
            setMessageStyle: (style) => setState(() => _messageStyle = style),
          );
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                ...fields,
                if (state is MacrosChangeSubmit && state.isSubmitting)
                  const Center(child: CircularProgressIndicator())
                else
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: ElevatedButton(
                        key: Key('save_predicted_calories_button'),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<MacrosChangeBloc>().add(
                              SubmitMacrosChange(),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB2F2BB),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.savePredictedCalories,
                        ),
                      ),
                    ),
                  ),
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
}
