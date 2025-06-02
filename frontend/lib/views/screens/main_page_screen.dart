import 'package:flutter/material.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/views/widgets/rectangular_button.dart';
import 'package:frontend/l10n/app_localizations.dart';

const double horizontalPaddingRatio = 0.05;
const double fontSizeRatio = 0.12;

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key});

  @override
  State<MainPageScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<MainPageScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = screenWidth * horizontalPaddingRatio;
    final dynamicFontSize = screenWidth * fontSizeRatio;

    return Scaffold(
      body: SingleChildScrollView(
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
                  AppLocalizations.of(context)!.hey,
                  style: Styles.kaushanScriptStyle(dynamicFontSize),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                ),
                child: Text(
                  UserStorage().getName!,
                  style: Styles.kaushanScriptStyle(dynamicFontSize),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          rectangularButton(
                            AppLocalizations.of(context)!.myAccount,
                            Icons.person,
                            screenWidth,
                            screenHeight,
                            () => context.push('/account'),
                          ),
                          const SizedBox(height: 16),
                          rectangularButton(
                            AppLocalizations.of(context)!.dietPreferences,
                            Icons.food_bank_rounded,
                            screenWidth,
                            screenHeight,
                            () => context.push('/profile_details'),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          rectangularButton(
                            "Button 3",
                            Icons.do_not_disturb,
                            screenWidth,
                            screenHeight,
                            null,
                          ),
                          const SizedBox(height: 16),
                          rectangularButton(
                            "Button 4",
                            Icons.do_not_disturb,
                            screenWidth,
                            screenHeight,
                            null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
