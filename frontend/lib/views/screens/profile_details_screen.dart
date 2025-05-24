import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/assets/profile_details/gender.pbenum.dart';
import 'package:frontend/blocs/diet_form_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/events/diet_form_events.dart';
import 'package:frontend/utils/profile_details_validators.dart';
import 'package:frontend/views/widgets/height_slider.dart';
import 'package:frontend/views/widgets/weight_slider.dart';
import 'package:intl/intl.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(AppConfig.profileDetails, style: AppConfig.titleStyle),
        ),
      ),
      body: _ProfileDetailsForm(),
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
  final TextStyle _messageStyle = AppConfig.errorStyle;

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
        key: Key(AppConfig.gender),
        value: _selectedGender,
        decoration: InputDecoration(labelText: AppConfig.gender),
        items:
            Gender.values.map((gender) {
              return DropdownMenuItem<Gender>(
                value: gender,
                child: Text(
                  AppConfig.genderLabels[gender]!,
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
        validator: (value) => validateGender(value),
      ),
      HeightSlider(
        initialValue: _selectedHeight,
        onChanged: (value) {
          setState(() {
            _selectedHeight = value;
          });
          context.read<DietFormBloc>().add(UpdateHeight(value));
        },
      ),
      WeightSlider(
        initialValue: _selectedWeight,
        label: AppConfig.weight,
        dialogTitle: AppConfig.enterYourWeight,
        onChanged: (value) {
          setState(() {
            _selectedWeight = value;
          });
          context.read<DietFormBloc>().add(UpdateWeight(value));
        },
      ),
      TextFormField(
        key: Key(AppConfig.dateOfBirth),
        controller: _dateOfBirthController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: AppConfig.dateOfBirth,
          suffixIcon: Icon(Icons.calendar_today),
        ),
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());

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

          if (pickedDate != null) {
            setState(() {
              final formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
              _dateOfBirthController.text = formattedDate;
            });

            context.read<DietFormBloc>().add(UpdateDateOfBirth(pickedDate));
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
