import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/config/styles.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/views/widgets/language_picker.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.homePage,
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.welcome,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: Text(AppLocalizations.of(context)!.login),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/register'),
              child: Text(AppLocalizations.of(context)!.register),
            ),
          ],
        ),
      ),
    );
  }
}
