import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user_details/diet_form_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/gender.dart';
import 'package:frontend/utils/user_details/profile_details_validators.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:frontend/views/widgets/height_slider.dart';
import 'package:frontend/views/widgets/weight_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.profileDetails,
            style: Styles.titleStyle,
          ),
        ),
      ),
      body: _ProfileDetailsForm(),
      bottomNavigationBar: BottomNavBar(
        currentRoute: GoRouterState.of(context).uri.path,
        mode: NavBarMode.wizard,
        prevRoute: '/main_page',
        nextRoute: '/diet_preferences',
      ),
    );
  }
}

class _ProfileDetailsForm extends StatefulWidget {
  @override
  State<_ProfileDetailsForm> createState() => _ProfileDetailsFormState();
}

class _ProfileDetailsFormState extends State<_ProfileDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  Gender? _selectedGender;
  double _selectedHeight = 175;
  double _selectedWeight = 65;
  String? _message;
  final TextStyle _messageStyle = Styles.errorStyle;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _genderController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      DropdownButtonFormField<Gender>(
        key: Key('gender'),
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.gender,
        ),
        items:
            Gender.values.map((gender) {
              return DropdownMenuItem<Gender>(
                value: gender,
                child: Text(
                  AppConfig.genderLabels(context)[gender]!,
                  style: TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedGender = value!;
          });
          context.read<DietFormBloc>().add(UpdateGender(value!));
        },
        validator: (value) => validateGender(value, context),
      ),
      HeightSlider(
        key: Key('height'),
        initialValue: _selectedHeight,
        onChanged: (value) {
          setState(() {
            _selectedHeight = value;
          });
          context.read<DietFormBloc>().add(UpdateHeight(value));
        },
      ),
      WeightSlider(
        key: Key('weight'),
        initialValue: _selectedWeight,
        label: AppLocalizations.of(context)!.weight,
        dialogTitle: AppLocalizations.of(context)!.enterYourWeight,
        onChanged: (value) {
          setState(() {
            _selectedWeight = value;
          });
          context.read<DietFormBloc>().add(UpdateWeight(value));
        },
      ),
      TextFormField(
        key: Key('date_of_birth'),
        controller: _dateOfBirthController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.dateOfBirth,
          suffixIcon: Icon(Icons.calendar_today),
        ),
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          final bloc = context.read<DietFormBloc>();

          final now = DateTime.now();
          final earliestDate = DateTime(now.year - 120, now.month, now.day);
          final latestDate = DateTime(now.year - 12, now.month, now.day);

          final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime(now.year - 30),
            firstDate: earliestDate,
            lastDate: latestDate,
            initialEntryMode: DatePickerEntryMode.calendar,
            initialDatePickerMode: DatePickerMode.year,
          );

          if (!mounted) return;

          if (pickedDate != null) {
            setState(() {
              final formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
              _dateOfBirthController.text = formattedDate;
            });

            bloc.add(UpdateDateOfBirth(pickedDate));
          }
        },
      ),
      if (_message != null)
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(_message!, style: _messageStyle),
        ),
    ];

    return Padding(
      padding: EdgeInsets.all(35.0),
      child: Form(
        key: _formKey,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: fields.length,
          separatorBuilder: (_, _) => SizedBox(height: 20),
          itemBuilder: (_, index) => fields[index],
        ),
      ),
    );
  }
}
