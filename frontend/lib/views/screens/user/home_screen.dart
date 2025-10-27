import 'package:flutter/material.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/views/widgets/language_picker.dart';
import 'package:frontend/views/widgets/title_text.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            ElevatedButton(
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.all(Size(200, 50)),
              ),
              onPressed: () => context.go('/login'),
              child: Text(AppLocalizations.of(context)!.login),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.all(Size(200, 50)),
              ),
              onPressed: () => context.go('/register'),
              child: Text(AppLocalizations.of(context)!.register),
            ),
            Spacer(flex: 6),
          ],
        ),
      ),
    );
  }
}
