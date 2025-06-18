import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app_router.dart';
import 'package:provider/provider.dart';

import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user/change_password_events.dart';
import 'package:frontend/listeners/user/change_password_listener.dart';
import 'package:frontend/models/user/change_password_request.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/change_password_states.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/utils/user/user_validators.dart';
import 'package:frontend/utils/query_parameters_mapper.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/blocs/user_details/change_password_bloc.dart';
import 'package:frontend/views/widgets/language_picker.dart';

class ChangePasswordScreen extends StatelessWidget {
  final ChangePasswordBloc? bloc;

  const ChangePasswordScreen({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    return bloc != null
        ? BlocProvider<ChangePasswordBloc>.value(
          value: bloc!,
          child: _buildScaffold(context),
        )
        : BlocProvider<ChangePasswordBloc>(
          create:
              (_) => ChangePasswordBloc(
                Provider.of<UserRepository>(context, listen: false),
                Provider.of<TokenStorageRepository>(context, listen: false),
              ),
          child: _buildScaffold(context),
        );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.changePassword,
            style: Styles.titleStyle,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.translate_rounded),
            onPressed: () => LanguagePicker.show(context),
          ),
        ],
      ),
      body: _ChangePasswordForm(),
    );
  }
}

class _ChangePasswordForm extends StatefulWidget {
  const _ChangePasswordForm();

  @override
  State<_ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<_ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  String? _message;
  String? _token;
  TextStyle _messageStyle = Styles.errorStyle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pathAndQuery = Uri.base.toString().split('?');
      if (pathAndQuery.length > 1) {
        final Map<String, String> queryParameters =
            QueryParametersMapper.parseQueryParams(pathAndQuery[1]);

        final token = queryParameters['token'];
        if (token != null && token.isNotEmpty) {
          setState(() {
            _token = token;
          });
        } else {
          router.go('/provide-email');
        }
      } else {
        router.go('/provide-email');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(35.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                key: Key('new_password'),
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newPassword,
                ),
                obscureText: true,
                validator: (value) => validatePassword(value, context),
              ),
              TextFormField(
                key: Key('confirm_password'),
                controller: _confirmNewPasswordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.confirmPassword,
                ),
                obscureText: true,
                validator:
                    (value) => validateConfirmPassword(
                      value,
                      _newPasswordController.text,
                      context,
                    ),
              ),
              const SizedBox(height: 20),
              BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
                listener: (context, state) {
                  ChangePasswordListenerHelper.onChangePasswordListener(
                    context: context,
                    state: state,
                    setState: setState,
                    mounted: mounted,
                    setMessage: (msg) => _message = msg,
                    setMessageStyle: (style) => _messageStyle = style,
                  );
                },
                builder: (context, state) {
                  if (state is ChangePasswordLoading) {
                    return const CircularProgressIndicator();
                  } else {
                    return ElevatedButton(
                      key: Key('change_password'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final request = ChangePasswordRequest(
                            email: _emailController.text,
                            newPassword: _newPasswordController.text,
                            token: _token!,
                          );
                          context.read<ChangePasswordBloc>().add(
                            ChangePasswordSubmitted(request),
                          );
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.changePassword),
                    );
                  }
                },
              ),
              if (_message != null)
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(_message!, style: _messageStyle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
