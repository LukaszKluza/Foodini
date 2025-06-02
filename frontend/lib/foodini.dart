import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/repository/user_details/user_details_repository.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:provider/provider.dart';

import 'app_router.dart';
import 'l10n/app_localizations.dart';

class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(const Locale('en'));

  void change(Locale locale) => emit(locale);
}

class Foodini extends StatelessWidget {
  const Foodini({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
        Provider<TokenStorageRepository>(
          create: (_) => TokenStorageRepository(),
        ),
        ProxyProvider<ApiClient, AuthRepository>(
          update: (_, apiClient, __) => AuthRepository(apiClient),
        ),
        ProxyProvider<ApiClient, UserDetailsRepository>(
          update: (_, apiClient, __) => UserDetailsRepository(apiClient),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LanguageCubit()),
          BlocProvider(
            create:
                (context) =>
                    DietFormBloc(context.read<UserDetailsRepository>()),
          ),
        ],
        child: BlocBuilder<LanguageCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              locale: locale,
              localeResolutionCallback:
                  (deviceLocale, supportedLocales) => locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
