import 'package:flutter/material.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/views/widgets/diet_generation/action_buttons.dart';
import 'package:frontend/views/widgets/language_picker.dart';
import 'package:frontend/views/widgets/title_text.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child:  Scaffold(
            appBar: AppBar(
              title: Stack(
                alignment: Alignment.center,
                children: [
                  TitleTextWidgets.scaledTitle(
                    AppLocalizations.of(context)!.welcome,
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
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(flex: 1),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Image.asset(Constants.mainFoodiniIcon),
                    ),
                  ),
                  Spacer(flex: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 72.0, vertical: 8.0),
                    child: Column(
                      children: [
                        customRedirectButton(
                            Key(AppLocalizations.of(context)!.login),
                                () => context.go('/login'),
                            Text(AppLocalizations.of(context)!.login)
                        ),
                        SizedBox(height: 16),
                        customSubmitButton(
                            Key(AppLocalizations.of(context)!.register),
                                () => context.go('/register'),
                            Text(AppLocalizations.of(context)!.register)
                        ),
                      ],
                    ),
                  ),
                  Spacer(flex: 6),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
