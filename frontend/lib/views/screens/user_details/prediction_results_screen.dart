import 'package:flutter/material.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/predicted_calories.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

class PredictionResultsScreen extends StatefulWidget {
  final PredictedCalories predictedCalories;

  const PredictionResultsScreen({super.key, required this.predictedCalories});

  @override
  State<PredictionResultsScreen> createState() =>
      _PredictionResultsScreenState();
}

class _PredictionResultsScreenState extends State<PredictionResultsScreen> {
  late TextEditingController _proteinController;
  late TextEditingController _fatController;
  late TextEditingController _carbsController;
  late TextEditingController _dietDurationController;

  final _formKey = GlobalKey<FormState>();

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
    return (protein * 4) + (fat * 9) + (carbs * 4);
  }

  String? _macrosValidator(String? _) {
    final total = _calculateCalories();
    final target = widget.predictedCalories.targetCalories;

    const tolerance = 30;

    if ((total - target).abs() > tolerance) {
      return 'Macros = $total kcal, expected ~ $target kcal';
    }
    return null;
  }

  Widget _buildMacroField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 400,
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          validator: _macrosValidator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final targetCalories = widget.predictedCalories.targetCalories;
    final bmr = widget.predictedCalories.bmr;
    final tdee = widget.predictedCalories.tdee;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.caloriesPrediction,
            style: Styles.titleStyle,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                child: Text(
                  '${AppLocalizations.of(context)!.predictedCalories}: $targetCalories kcal',
                  style: Styles.titleStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: Text(
                  '${AppLocalizations.of(context)!.bmr}: $bmr kcal',
                  style: Styles.titleStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Text(
                  '${AppLocalizations.of(context)!.tdee}: $tdee kcal',
                  style: Styles.titleStyle,
                  textAlign: TextAlign.center,
                ),
              ),
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
                child: _buildMacroField('Protein (g)', _proteinController),
              ),
              Center(child: _buildMacroField('Fat (g)', _fatController)),
              Center(child: _buildMacroField('Carbs (g)', _carbsController)),

              if (widget.predictedCalories.dietDurationDays != null)
                Center(
                  child: SizedBox(
                    width: 400,
                    child: TextFormField(
                      controller: _dietDurationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.dietDuration,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentRoute: GoRouterState.of(context).uri.path,
        mode: NavBarMode.wizard,
        prevRoute: '/calories-prediction',
      ),
    );
  }
}
