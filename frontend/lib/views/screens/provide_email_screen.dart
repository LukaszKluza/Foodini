import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/provide_email_block.dart';
import 'package:frontend/events/provide_email_events.dart';
import 'package:frontend/listeners/provide_email_listener.dart';
import 'package:frontend/models/provide_email_request.dart';
import 'package:frontend/states/provide_email_states.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/repository/auth_repository.dart';
import 'package:frontend/utils/user_validators.dart';

class ProvideEmailScreen extends StatelessWidget {
  final ProvideEmailBloc? bloc;

  const ProvideEmailScreen({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    return bloc != null
        ? BlocProvider<ProvideEmailBloc>.value(
          value: bloc!,
          child: _buildScaffold(context),
        )
        : BlocProvider<ProvideEmailBloc>(
          create:
              (_) => ProvideEmailBloc(
                Provider.of<AuthRepository>(context, listen: false),
              ),
          child: _buildScaffold(context),
        );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(AppConfig.changePassword, style: Styles.titleStyle),
        ),
      ),
      body: _ProvideEmailForm(),
      bottomNavigationBar: BottomNavBar(
        currentRoute: GoRouterState.of(context).uri.path,
      ),
    );
  }
}

class _ProvideEmailForm extends StatefulWidget {
  const _ProvideEmailForm();

  @override
  State<_ProvideEmailForm> createState() => _ProvideEmailFormState();
}

class _ProvideEmailFormState extends State<_ProvideEmailForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  String? _message;
  TextStyle _messageStyle = Styles.errorStyle;

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
              const SizedBox(height: 20),
              BlocConsumer<ProvideEmailBloc, ProvideEmailState>(
                listener: (context, state) {
                  ProvideEmailListenerHelper.onProvideEmailListener(
                    context: context,
                    state: state,
                    setState: setState,
                    mounted: mounted,
                    setMessage: (msg) => _message = msg,
                    setMessageStyle: (style) => _messageStyle = style,
                  );
                },
                builder: (context, state) {
                  if (state is ProvideEmailLoading) {
                    return const CircularProgressIndicator();
                  } else {
                    return ElevatedButton(
                      key: Key(AppConfig.changePassword),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final request = ProvideEmailRequest(
                            email: _emailController.text,
                          );
                          context.read<ProvideEmailBloc>().add(
                            ProvideEmailSubmitted(request),
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
