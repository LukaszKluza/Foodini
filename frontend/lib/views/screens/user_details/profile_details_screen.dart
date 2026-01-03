import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/events/user_details/diet_form_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/gender.dart';
import 'package:frontend/states/diet_form_states.dart';
import 'package:frontend/utils/user_details/profile_details_validators.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:frontend/views/widgets/title_text.dart';
import 'package:frontend/views/widgets/user_details/height_slider.dart';
import 'package:frontend/views/widgets/user_details/weight_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  bool _isFormValid = false;

  void _onFormValidityChanged(bool isValid) {
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child:Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Center(
                child: TitleTextWidgets.scaledTitle(AppLocalizations.of(context)!.profileDetails),
              ),
            ),
            body: _ProfileDetailsForm(onFormValidityChanged: _onFormValidityChanged),
            bottomNavigationBar: BottomNavBar(
              currentRoute: GoRouterState.of(context).uri.path,
              mode: NavBarMode.wizard,
              prevRoute: '/main-page',
              nextRoute: '/diet-preferences',
              isNextRouteEnabled: _isFormValid,
            ),
          ),
        ),
      )
    );
  }
}

class _ProfileDetailsForm extends StatefulWidget {
  final ValueChanged<bool>? onFormValidityChanged;

  const _ProfileDetailsForm({this.onFormValidityChanged});

  @override
  State<_ProfileDetailsForm> createState() => _ProfileDetailsFormState();
}

class _ProfileDetailsFormState extends State<_ProfileDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  bool _didEnter = false;

  Gender? _selectedGender;
  double _selectedHeight = Constants.defaultHeight;
  double _selectedWeight = Constants.defaultWeight;
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final blocState = context.read<DietFormBloc>().state;
    final state = GoRouterState.of(context);
    final from = (state.extra as Map?)?['from'];
    if (from == 'main-page' && !_didEnter) {
      _didEnter = true;
      context.read<DietFormBloc>().add(InitForm());
    }

    if (blocState is DietFormSubmit) {
      _selectedGender = blocState.gender ?? _selectedGender;
      _selectedHeight = blocState.height ?? _selectedHeight;
      _selectedWeight = blocState.weight ?? _selectedWeight;
      _selectedDateOfBirth = blocState.dateOfBirth ?? _selectedDateOfBirth;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _softFormValidation(),
      );
    }
  }

  void _softFormValidation() {
    final formIsReady = _selectedGender != null && _selectedDateOfBirth != null;

    widget.onFormValidityChanged?.call(formIsReady);
  }

  void _updateStateAndBloc<T>({
    required void Function() updateState,
    required DietFormEvent blocEvent,
  }) {
    setState(updateState);
    context.read<DietFormBloc>().add(blocEvent);
    _softFormValidation();
  }

  void _onGenderChanged(Gender? value) {
    _updateStateAndBloc(
      updateState: () => _selectedGender = value,
      blocEvent: UpdateGender(value!),
    );
  }

  void _onHeightChanged(double value) {
    _updateStateAndBloc(
      updateState: () => _selectedHeight = value,
      blocEvent: UpdateHeight(value),
    );
  }

  void _onWeightChanged(double value) {
    _updateStateAndBloc(
      updateState: () => _selectedWeight = value,
      blocEvent: UpdateWeight(value),
    );
  }

  void _onDateOfBirthPicked(DateTime? pickedDate) {
    if (pickedDate == null) return;
    _updateStateAndBloc(
      updateState: () => _selectedDateOfBirth = pickedDate,
      blocEvent: UpdateDateOfBirth(pickedDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateOfBirthController = TextEditingController(
      text:
          _selectedDateOfBirth != null
              ? DateFormat('dd/MM/yyyy').format(_selectedDateOfBirth!)
              : '',
    );

    return BlocListener<DietFormBloc, DietFormState>(
      listener: (context, state) {
        if (state is DietFormSubmit) {
          setState(() {
            _selectedGender = state.gender ?? _selectedGender;
            _selectedHeight = state.height ?? _selectedHeight;
            _selectedWeight = state.weight ?? _selectedWeight;
            _selectedDateOfBirth = state.dateOfBirth ?? _selectedDateOfBirth;
          });
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _softFormValidation(),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              DropdownButtonFormField<Gender>(
                key: const Key('gender'),
                isExpanded: true,
                initialValue: _selectedGender,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.gender,
                ),
                items:
                  Gender.values
                    .map(
                      (gender) => DropdownMenuItem<Gender>(
                        value: gender,
                        child: Text(
                          AppConfig.genderLabels(context)[gender]!,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ).toList(),
                onChanged: _onGenderChanged,
                validator: (value) => validateGender(value, context),
              ),
              const SizedBox(height: 20),
              HeightSlider(
                key: const Key('height'),
                value: _selectedHeight,
                onChanged: _onHeightChanged,
              ),
              const SizedBox(height: 20),
              WeightSlider(
                key: const Key('weight'),
                value: _selectedWeight,
                label: AppLocalizations.of(context)!.weight,
                dialogTitle: AppLocalizations.of(context)!.enterYourWeight,
                onChanged: _onWeightChanged,
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: const Key('date_of_birth'),
                controller: dateOfBirthController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.dateOfBirth,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (_selectedDateOfBirth == null) {
                    return AppLocalizations.of(context)!.enterDateOfBirth;
                  }
                  return null;
                },
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());

                  final now = DateTime.now();
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateOfBirth ?? DateTime(now.year - 30),
                    firstDate: DateTime(now.year - 120),
                    lastDate: DateTime(now.year - 12),
                    initialEntryMode: DatePickerEntryMode.calendar,
                    initialDatePickerMode: DatePickerMode.year,
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
                    },
                  );

                  if (pickedDate != null) {
                    _onDateOfBirthPicked(pickedDate);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
