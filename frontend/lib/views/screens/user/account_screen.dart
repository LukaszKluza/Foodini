import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/events/user_details/diet_form_events.dart';
import 'package:frontend/utils/responsive_font_size.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:frontend/views/widgets/language_picker.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:frontend/blocs/user/account_bloc.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/user/account_events.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/account_states.dart';
import 'package:frontend/views/widgets/rectangular_button.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/listeners/user/account_listener.dart';

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
                Provider.of<UserRepository>(context, listen: false),
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

    final horizontalPadding = screenWidth * Constants.horizontalPaddingRatio;
    final nameFontSize = ResponsiveUtils.scaledFontSize(
      context,
      Constants.nameFontRatio,
    );
    final labelFontSize = ResponsiveUtils.scaledFontSize(
      context,
      Constants.labelFontRatio,
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    bottom: 4.0,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.your,
                    style: Styles.kaushanScriptStyle(nameFontSize),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.account,
                    style: Styles.kaushanScriptStyle(labelFontSize),
                  ),
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.all(20.0),
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
                            () => context.push('/provide-email'),
                          ),
                          const SizedBox(height: 16),
                          Builder(
                            builder:
                                (context) => rectangularButton(
                                  AppLocalizations.of(context)!.logout,
                                  Icons.logout,
                                  screenWidth,
                                  screenHeight,
                                  () {
                                    context.read<AccountBloc>().add(
                                      AccountLogoutRequested(),
                                    );
                                    context.read<DietFormBloc>().add(
                                      DietFormResetRequested(),
                                    );
                                  },
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
                                  () => LanguagePicker.show(
                                    context,
                                    isAccountScreen: true,
                                  ),
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
      ),
      bottomNavigationBar: BottomNavBar(
        currentRoute: GoRouterState.of(context).uri.path,
      ),
    );
  }
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
                      mainContext.read<DietFormBloc>().add(
                        DietFormResetRequested(),
                      );
                    },
                    child: Text(AppLocalizations.of(mainContext)!.delete),
                  ),
                ],
              ),
        ),
  );
}
