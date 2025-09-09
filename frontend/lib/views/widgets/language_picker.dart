import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user/account_bloc.dart';
import 'package:frontend/events/user/account_events.dart';
import 'package:frontend/foodini.dart';
import 'package:frontend/models/user/change_language_request.dart';
import 'package:frontend/models/user/language.dart';

class LanguagePicker {
  static void show(BuildContext mainContext, {bool isAccountScreen = false}) {
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
                    title: Text(
                      lang.name,
                      style: const TextStyle(fontSize: 20),
                    ),
                    onTap: () {
                      if (isAccountScreen) {
                        final request = ChangeLanguageRequest(language: lang);
                        mainContext.read<AccountBloc>().add(
                          AccountChangeLanguageRequested(request),
                        );
                      } else {
                        context.read<LanguageCubit>().change(lang);
                      }
                      Navigator.of(dialogContext).pop();
                    },
                  );
                },
              ),
        );
      },
    );
  }
}
