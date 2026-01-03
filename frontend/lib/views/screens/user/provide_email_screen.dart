import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user/provide_email_block.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user/provide_email_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/listeners/user/provide_email_listener.dart';
import 'package:frontend/models/user/provide_email_request.dart';
import 'package:frontend/repository/api_client.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/states/provide_email_states.dart';
import 'package:frontend/utils/user/user_validators.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:frontend/views/widgets/diet_generation/action_buttons.dart';
import 'package:frontend/views/widgets/language_picker.dart';
import 'package:frontend/views/widgets/title_text.dart';
import 'package:go_router/go_router.dart';

class ProvideEmailScreen extends StatelessWidget {
  final ProvideEmailBloc? bloc;

  const ProvideEmailScreen({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    final wrappedScaffold = Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
            child: _buildScaffold(context)
        ),
      ),
    );

    if (bloc != null) {
      return BlocProvider<ProvideEmailBloc>.value(
        value: bloc!,
        child: wrappedScaffold,
      );
    }

    return BlocProvider<ProvideEmailBloc>(
      create: (_) => ProvideEmailBloc(
        context.read<UserRepository>(),
        apiClient: context.read<ApiClient>(),
      ),
      child: wrappedScaffold,
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Stack(
          alignment: Alignment.center,
          children: [
            TitleTextWidgets.scaledTitle(
              AppLocalizations.of(context)!.changePassword,
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
        padding: const EdgeInsets.fromLTRB(35, 16, 35, 16),
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
              const SizedBox(height: 20),
              BlocConsumer<ProvideEmailBloc, ProvideEmailState>(
                listener: (context, state) {
                  ProvideEmailListenerHelper.onProvideEmailListener(
                    context: context,
                    state: state,
                    mounted: mounted,
                    setMessage: (msg) => setState(() => _message = msg),
                    setMessageStyle: (style) => setState(() => _messageStyle = style),
                  );
                },
                builder: (context, state) {
                  if (state is ProvideEmailLoading) {
                    return const CircularProgressIndicator();
                  } else {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: SizedBox(
                          width: double.infinity,
                          child: customSubmitButton(
                            Key('change_password'),
                            () {
                              if (_formKey.currentState!.validate()) {
                                final request = ProvideEmailRequest(
                                  email: _emailController.text,
                                );
                                context.read<ProvideEmailBloc>().add(
                                  ProvideEmailSubmitted(request),
                                );
                              }
                            },
                            Text(AppLocalizations.of(context)!.changePassword),
                          ),
                        ),
                      ),
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
