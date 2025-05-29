import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/config/app_config.dart';
import 'package:frontend/views/widgets/rectangular_button.dart';

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
      body: Padding(
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
                'Hey',
                style: TextStyle(fontSize: dynamicFontSize, fontFamily: 'KaushanScript'),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding),
              child: Text(
                'Simone!',
                style: TextStyle(fontSize: dynamicFontSize, fontFamily: 'KaushanScript'),
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
                          AppConfig.myAccount,
                          Icons.person,
                          screenWidth,
                          screenHeight,
                          () => context.go('/account'),
                        ),
                        const SizedBox(height: 16),
                        rectangularButton(
                          AppConfig.dietPreferences,
                          Icons.food_bank_rounded,
                          screenWidth,
                          screenHeight,
                          () => context.go('/profile_details'),
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
    );
  }
}
