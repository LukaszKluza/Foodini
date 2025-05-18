import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:frontend/blocs/change_password_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/events/change_password_events.dart';
import 'package:frontend/listeners/change_password_listener.dart';
import 'package:frontend/models/change_password_request.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/change_password_states.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/utils/user_validators.dart';
import 'package:frontend/utils/query_parameters_mapper.dart';

class ChangePasswordScreen extends StatelessWidget {
  final ChangePasswordBloc? bloc;

  const ChangePasswordScreen({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    return bloc != null
        ? BlocProvider<ChangePasswordBloc>.value(
          value: bloc!,
          child: _buildScaffold(),
        )
        : BlocProvider<ChangePasswordBloc>(
          create:
              (_) => ChangePasswordBloc(
                Provider.of<AuthRepository>(context, listen: false),
                Provider.of<TokenStorageRepository>(context, listen: false),
              ),
          child: _buildScaffold(),
        );
  }

  Widget _buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(AppConfig.changePassword, style: AppConfig.titleStyle),
        ),
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
  TextStyle _messageStyle = AppConfig.errorStyle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pathAndQuery = Uri.base.toString().split('?');
      if (pathAndQuery.length > 1) {
        final Map<String, String> queryParameters =
            QueryParametersMapper.parseQueryParams(pathAndQuery[1]);

        if (queryParameters["token"] != null) {
          setState(() {
            _token = queryParameters["token"];
          });
        }
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
                key: Key(AppConfig.email),
                controller: _emailController,
                decoration: InputDecoration(labelText: AppConfig.email),
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              TextFormField(
                key: Key(AppConfig.newPassword),
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: AppConfig.newPassword),
                obscureText: true,
                validator: validatePassword,
              ),
              TextFormField(
                key: Key(AppConfig.confirmPassword),
                controller: _confirmNewPasswordController,
                decoration: InputDecoration(
                  labelText: AppConfig.confirmPassword,
                ),
                obscureText: true,
                validator:
                    (value) => validateConfirmPassword(
                      value,
                      _newPasswordController.text,
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
                      key: Key(AppConfig.changePassword),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_token == null || _token!.isEmpty) {
                            setState(() {
                              _message = AppConfig.wrongChangePasswordUrl;
                              _messageStyle = AppConfig.errorStyle;
                            });
                            return;
                          }
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
                      child: Text(AppConfig.changePassword),
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
