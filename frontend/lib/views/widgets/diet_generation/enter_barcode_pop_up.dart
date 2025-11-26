import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/diet_generation/daily_summary_bloc.dart';
import 'package:frontend/events/diet_generation/daily_summary_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/utils/diet_generation/meal_item_validators.dart';
import 'package:frontend/views/widgets/diet_generation/action_button.dart';
import 'package:image_picker/image_picker.dart';

class EnterBarcodePopup extends StatefulWidget {
  final DateTime day;
  final MealType mealType;

  const EnterBarcodePopup({
    super.key,
    required this.day,
    required this.mealType,
  });

  @override
  State<EnterBarcodePopup> createState() => _EnterBarcodePopupState();
}

class _EnterBarcodePopupState extends State<EnterBarcodePopup> {
  final formKey = GlobalKey<FormState>();
  XFile? uploadedFile;
  bool productAdded = false;

  late TextEditingController barcodeController;

  @override
  void initState() {
    super.initState();
    barcodeController = TextEditingController();
  }

  @override
  void dispose() {
    barcodeController.dispose();
    super.dispose();
  }

  Widget editableField(
    TextEditingController controller,
    Function(String?) validator,
    String label, {
    TextInputType? type = TextInputType.number,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        errorMaxLines: 2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: type,
      validator: (value) => validator(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                editableField(
                  barcodeController,
                  (value) => validateBarcode(value, context),
                  AppLocalizations.of(context)!.productBarCode,
                  type: TextInputType.text,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ActionButton(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery);

                        if (picked == null) return;
                        if (!mounted) return;

                        setState(() {
                          uploadedFile = picked;
                        });
                      },
                      color: Colors.orangeAccent,
                      label: AppLocalizations.of(context)!.uploadBarCodeImage,
                    ),
                  ],
                ),
                if (uploadedFile != null || productAdded)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      uploadedFile != null
                          ? '${AppLocalizations.of(context)!.readFile} ${uploadedFile!.name}'
                          : AppLocalizations.of(context)!.barcodeUploaded,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[900],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ActionButton(
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey[500]!,
                      label: AppLocalizations.of(context)!.cancel,
                    ),
                    const SizedBox(width: 12),
                    ActionButton(
                      onPressed: () {
                        if (uploadedFile != null || formKey.currentState!.validate()) {
                          var event = AddScannedProduct(barcode: barcodeController.text, uploadedFile: uploadedFile, mealType: widget.mealType);
                          context.read<DailySummaryBloc>().add(event);

                          setState(() {
                            uploadedFile = null;
                            barcodeController.clear();
                            productAdded = true;
                          });

                          Future.delayed(Duration(seconds: 3), () {
                            if (mounted) {
                              setState(() {
                                productAdded = false;
                              });
                            }
                          });
                        }
                      },
                      color: Colors.lightGreen,
                      label: AppLocalizations.of(context)!.addProduct,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
