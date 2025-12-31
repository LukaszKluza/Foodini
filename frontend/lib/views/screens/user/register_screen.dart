import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user/register_bloc.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user/register_events.dart';
import 'package:frontend/foodini.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/listeners/user/register_listener.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/models/user/register_request.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/states/register_states.dart';
import 'package:frontend/utils/user/user_validators.dart';
import 'package:frontend/views/widgets/language_picker.dart';
import 'package:frontend/views/widgets/title_text.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  final RegisterBloc? bloc;

  const RegisterScreen({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    return bloc != null
        ? BlocProvider<RegisterBloc>.value(
          value: bloc!,
          child: _buildScaffold(context),
        )
        : BlocProvider<RegisterBloc>(
          create:
              (_) => RegisterBloc(
                Provider.of<UserRepository>(context, listen: false),
              ),
          child: _buildScaffold(context),
        );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Stack(
          alignment: Alignment.center,
          children: [
            TitleTextWidgets.scaledTitle(
              AppLocalizations.of(context)!.registration,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.translate_rounded),
                onPressed: () => LanguagePicker.show(context),
              ),
            ),
          ],
        ),
      ),
      body: _RegisterForm(),
    );
  }
}

class _RegisterForm extends StatefulWidget {
  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedCountry;
  String? _message;
  TextStyle _messageStyle = Styles.errorStyle;

  void _pickCountry(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country.name;
          _countryController.text = _selectedCountry ?? '';
        });
      },
    );
  }

  Language getLanguage(BuildContext context){
    final locale = context.read<LanguageCubit>().state;
    return Language.fromJson(locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(35, 16, 35, 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                key: Key('first_name'),
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.firstName,
                ),
                validator: (value) => validateName(value, context),
              ),
              TextFormField(
                key: Key('last_name'),
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.lastName,
                ),
                validator: (value) => validateLastname(value, context),
              ),
              TextFormField(
                key: Key('country'),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.country,
                ),
                controller: _countryController,
                onTap: () => _pickCountry(context),
                validator: (value) => validateCountry(value, context),
              ),
              TextFormField(
                key: Key('e-mail'),
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => validateEmail(value, context),
              ),
              TextFormField(
                key: Key('password'),
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.password,
                ),
                obscureText: true,
                validator: (value) => validatePassword(value, context),
              ),
              TextFormField(
                key: Key('confirm_password'),
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.confirmPassword,
                ),
                obscureText: true,
                validator:
                    (value) => validateConfirmPassword(
                      value,
                      _passwordController.text,
                      context,
                    ),
              ),
              SizedBox(height: 20),
              BlocConsumer<RegisterBloc, RegisterState>(
                listener: (context, state) {
                  RegisterListenerHelper.onRegisterListener(
                    context: context,
                    state: state,
                    mounted: mounted,
                    setMessage: (msg) => setState(() => _message = msg),
                    setMessageStyle: (style) => setState(() => _messageStyle = style),
                  );
                },
                builder: (context, state) {
                  if (state is RegisterLoading) {
                    return CircularProgressIndicator();
                  } else {
                    return ElevatedButton(
                      key: Key('register'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final request = RegisterRequest(
                            name: _firstNameController.text,
                            lastName: _lastNameController.text,
                            country: _selectedCountry ?? '',
                            email: _emailController.text,
                            password: _passwordController.text,
                            language: getLanguage(context)
                          );
                          context.read<RegisterBloc>().add(
                            RegisterSubmitted(request),
                          );
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.register),
                    );
                  }
                },
              ),
              if (_message != null)
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(_message!, style: _messageStyle),
                ),
              TextButton(
                key: Key('already_have_an_account'),
                onPressed: () => context.go('/login'),
                child: Text(AppLocalizations.of(context)!.alreadyHaveAnAccount),
              ),
              TextButton(
                key: Key('home'),
                onPressed: () => context.go('/'),
                child: Text(AppLocalizations.of(context)!.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
