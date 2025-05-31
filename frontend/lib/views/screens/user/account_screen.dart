import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:frontend/blocs/user/account_bloc.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user/account_events.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/account_states.dart';
import 'package:frontend/views/widgets/rectangular_button.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/listeners/user/account_listener.dart';
import 'package:frontend/models/user/change_language_request.dart';

class AccountScreen extends StatelessWidget {
  final AccountBloc? bloc;

  const AccountScreen({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    return bloc != null
        ? BlocProvider<AccountBloc>.value(value: bloc!, child: _AccountBody())
        : BlocProvider<AccountBloc>(
          create:
              (_) => AccountBloc(
                Provider.of<AuthRepository>(context, listen: false),
                Provider.of<TokenStorageRepository>(context, listen: false),
              ),
          child: _AccountBody(),
        );
  }
}

class _AccountBody extends StatefulWidget {
  @override
  State<_AccountBody> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<_AccountBody> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/main_page');
          },
        ),
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.foodini,
            style: Styles.titleStyle,
          ),
        ),
      ),
      body: BlocListener<AccountBloc, AccountState>(
        listener: (context, state) {
          AccountListenerHelper.accountStateListener(
            context,
            state,
            mounted: mounted,
          );
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(35.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        rectangularButton(
                          AppLocalizations.of(context)!.changePassword,
                          Icons.settings,
                          screenWidth,
                          screenHeight,
                          () => context.go('/provide_email'),
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder:
                              (context) => rectangularButton(
                                AppLocalizations.of(context)!.logout,
                                Icons.logout,
                                screenWidth,
                                screenHeight,
                                () => context.read<AccountBloc>().add(
                                  AccountLogoutRequested(),
                                ),
                              ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Builder(
                          builder:
                              (context) => rectangularButton(
                                AppLocalizations.of(context)!.changeLanguage,
                                Icons.translate_rounded,
                                screenWidth,
                                screenHeight,
                                () => _pickLanguage(context),
                              ),
                        ),
                        const SizedBox(height: 16),
                        Builder(
                          builder:
                              (context) => rectangularButton(
                                AppLocalizations.of(context)!.deleteAccount,
                                Icons.auto_delete,
                                screenWidth,
                                screenHeight,
                                () => _showDeleteAccountDialog(context),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              BlocBuilder<AccountBloc, AccountState>(
                builder: (context, state) {
                  if (state is AccountActionInProgress) {
                    return const CircularProgressIndicator();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _pickLanguage(BuildContext mainContext) {
  final languages = Language.values;

  showModalBottomSheet(
    context: mainContext,
    builder: (dialogContext) {
      return Builder(
        builder:
            (innerContext) => ListView.builder(
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final lang = languages[index];
                return ListTile(
                  leading: Text(
                    lang.flag,
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(lang.name, style: const TextStyle(fontSize: 20)),
                  onTap: () {
                    final request = ChangeLanguageRequest(language: lang);
                    mainContext.read<AccountBloc>().add(
                      AccountChangeLanguageRequested(request),
                    );
                    Navigator.of(dialogContext).pop();
                  },
                );
              },
            ),
      );
    },
  );
}

void _showDeleteAccountDialog(BuildContext mainContext) {
  showDialog(
    context: mainContext,
    builder:
        (dialogContext) => Builder(
          builder:
              (innerContext) => AlertDialog(
                title: Text(
                  AppLocalizations.of(mainContext)!.confirmAccountDeletion,
                ),
                content: Text(
                  AppLocalizations.of(mainContext)!.accountDeletionInformation,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: Text(AppLocalizations.of(mainContext)!.cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      mainContext.read<AccountBloc>().add(
                        AccountDeleteRequested(),
                      );
                    },
                    child: Text(AppLocalizations.of(mainContext)!.delete),
                  ),
                ],
              ),
        ),
  );
}
