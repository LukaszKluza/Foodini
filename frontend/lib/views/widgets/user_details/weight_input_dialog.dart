import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user_details/user_statistics_bloc.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/events/user_details/user_statistics_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/processing_status.dart';
import 'package:frontend/models/user_details/user_weight_history.dart';
import 'package:frontend/states/user_statistics_states.dart';

class WeightInputDialog {
  static Future<void> show(BuildContext context, DateTime startDate, DateTime endDate) {
    return showDialog(
      context: context,
      builder: (_) => _WeightInputDialog(startDate, endDate),
    );
  }
}

class _WeightInputDialog extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const _WeightInputDialog(this.startDate, this.endDate);

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
    context.read<UserStatisticsBloc>().add(LoadUserWeightForDay(selectedDate));
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDatePickerMode: DatePickerMode.day,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange.shade800,
              ),
            ),
          ),
          child: child!,
        );
      }
    );

    if (!mounted) return;

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      context.read<UserStatisticsBloc>().add(LoadUserWeightForDay(selectedDate));
    }
  }

  Future<void> _save() async {
    final text = weightController.text.trim().replaceAll(',', '.');
    final parsed = double.tryParse(text);

    if (parsed == null || parsed < Constants.minHeight || parsed > Constants.maxWeight) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.valueOfWeightShouldBeBetween),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final entry = UserWeightHistory(
      weightKg: parsed,
      day: selectedDate,
    );

    context.read<UserStatisticsBloc>().add(
        UpdateUserWeight(widget.startDate, widget.endDate, entry)
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocListener<UserStatisticsBloc, UserStatisticsState>(
      listenWhen: (previous, current) =>
          previous.processingStatus != current.processingStatus,
      listener: (context, state) {
        if (state.processingStatus == ProcessingStatus.submittingSuccess) {
          Navigator.of(context).pop();
        } else if (state.processingStatus == ProcessingStatus.submittingFailure) {
          final errorMessage =
              state.getMessage?.call(context) ?? loc.unknownError;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      },
      child: BlocBuilder<UserStatisticsBloc, UserStatisticsState>(
        builder: (context, state) {
          final isSubmitting =
              state.processingStatus == ProcessingStatus.submittingOnGoing;

          final dailyWeight = state.dailyWeight;
          if (dailyWeight != null) {
            final newText = dailyWeight.weightKg.toStringAsFixed(1);
            if (weightController.text != newText) {
              weightController.text = newText;
            }
          } else {
            weightController.text = '';
          }

          return AlertDialog(
            title: Text(loc.enterYourWeight),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedDate.toIso8601String().split('T').first,
                      ),
                    ),
                    IconButton(
                      onPressed: isSubmitting ? null : _pickDate,
                      icon: const Icon(Icons.edit_calendar_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: loc.weightKg,
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed:
                    isSubmitting ? null : () => Navigator.pop(context),
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  )
                ),
              ),
              ElevatedButton.icon(
                onPressed: isSubmitting ? null : _save,
                icon: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                    Icons.save_outlined,
                    color: Colors.orange,
                ),
                label:
                  Text(
                    MaterialLocalizations.of(context).okButtonLabel,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ),
            ],
          );
        },
      ),
    );
  }
}
