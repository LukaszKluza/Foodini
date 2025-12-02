import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user_details/user_statistics_bloc.dart';
import 'package:frontend/events/user_details/user_statistics_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/processing_status.dart';
import 'package:frontend/models/user_details/user_weight_history.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/states/user_statistics_states.dart';

class WeightInputDialog {
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => _WeightInputDialog(),
    );
  }
}

class _WeightInputDialog extends StatefulWidget {
  @override
  State<_WeightInputDialog> createState() => _WeightInputDialogState();
}

class _WeightInputDialogState extends State<_WeightInputDialog> {
  late DateTime selectedDate;
  late final TextEditingController weightController;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    weightController = TextEditingController();
    _loadExistingWeight();
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingWeight() async {
    final repo = context.read<UserStatisticsBloc>().userDetailsRepository;
    final userId = UserStorage().getUserId!;

    try {
      final existing = await repo.getUserWeightForDay(selectedDate, userId);
      if (mounted) {
        final weightText = existing?.weightKg.toStringAsFixed(1) ?? '';
        if (weightController.text != weightText) {
          setState(() {
            weightController.text = weightText;
          });
        }
      }
    } catch (_) {
      // Idk what to do here, maybe just pass
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      await _loadExistingWeight();
    }
  }

  Future<void> _save() async {
    final text = weightController.text.trim().replaceAll(',', '.');
    final parsed = double.tryParse(text);

    if (parsed == null || parsed < 20 || parsed > 160) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.valueOfWeightShouldBeBetween),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final entry = UserWeightHistory(weightKg: parsed, day: selectedDate);
    context.read<UserStatisticsBloc>().add(UpdateUserWeight(entry));

  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final bloc = context.read<UserStatisticsBloc>();

    return BlocListener<UserStatisticsBloc, UserStatisticsState>(
      bloc: bloc,
      listenWhen: (previous, current) => previous.processingStatus != current.processingStatus,
      listener: (context, state) {
        if (state.processingStatus == ProcessingStatus.submittingSuccess) {
          Navigator.of(context).pop(true);
        } else if (state.processingStatus == ProcessingStatus.submittingFailure) {
          final errorMessage = state.getMessage?.call(context) ?? loc.unknownError;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<UserStatisticsBloc, UserStatisticsState>(
        bloc: bloc,
        builder: (context, state) {
          final isSubmitting = state.processingStatus == ProcessingStatus.submittingOnGoing;

          return AlertDialog(
            title: Text(loc.enterYourWeight),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(selectedDate.toIso8601String().split('T').first)),
                    IconButton(
                      onPressed: isSubmitting ? null : _pickDate,
                      icon: const Icon(Icons.edit_calendar_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: loc.weightKg,
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context, false),
                child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              ElevatedButton.icon(
                onPressed: isSubmitting ? null : _save,
                icon: isSubmitting
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_outlined),
                label: Text(MaterialLocalizations.of(context).okButtonLabel),
              )
            ],
          );
        }
      ),
    );
  }
}