import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/app_router.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/blocs/user_details/macros_change_bloc.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/repository/api_client.dart';
import 'package:frontend/repository/diet_generation/diet_prediction_repository.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/repository/user_details/user_details_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:provider/provider.dart';

class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(const Locale('en')) {
    _loadUserLang();
  }

  Future<void> _loadUserLang() async {
    final user = UserStorage().getUser;
    if (user?.language.code != null) {
      change(user!.language);
    }
  }

  Future<void> change(Language language) async {
    emit(Locale(language.code.toLowerCase()));
    await UserStorage().updateLanguage(language);
  }
}

class Foodini extends StatelessWidget {
  const Foodini({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
        Provider<TokenStorageService>(
          create: (_) => TokenStorageService(),
        ),
        ProxyProvider<ApiClient, UserRepository>(
          update: (_, apiClient, __) => UserRepository(apiClient),
        ),
        ProxyProvider<ApiClient, UserDetailsRepository>(
          update: (_, apiClient, __) => UserDetailsRepository(apiClient),
        ),
        ProxyProvider<ApiClient, DietPredictionRepository>(
          update: (_, apiClient, __) => DietPredictionRepository(apiClient),
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
          BlocProvider(
            create:
                (context) =>
                    MacrosChangeBloc(context.read<UserDetailsRepository>()),
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
