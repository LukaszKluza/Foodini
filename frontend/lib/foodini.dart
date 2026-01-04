import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/app_router.dart';
import 'package:frontend/blocs/diet_generation/daily_summary_bloc.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/blocs/user_details/macros_change_bloc.dart';
import 'package:frontend/blocs/user_details/user_statistics_bloc.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/repository/api_client.dart';
import 'package:frontend/repository/diet_generation/diet_generation_repository.dart';
import 'package:frontend/repository/diet_generation/meals_repository.dart';
import 'package:frontend/repository/user/user_repository.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/repository/user_details/user_details_repository.dart';
import 'package:frontend/services/token_storage_service.dart';
import 'package:frontend/states/diet_generation/daily_summary_states.dart';
import 'package:frontend/utils/cache_manager.dart';
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
  final Directory? appDir;

  const Foodini(this.appDir, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
        Provider<TokenStorageService>(
          create: (_) => TokenStorageService(),
        ),
        ProxyProvider<ApiClient, CacheManager>(
          update: (_, apiClient, _) => CacheManager(apiClient, appDir),
        ),
        ProxyProvider<ApiClient, UserRepository>(
          update: (_, apiClient, _) => UserRepository(apiClient),
        ),
        ProxyProvider2<ApiClient, CacheManager, UserDetailsRepository>(
          update: (_, apiClient, cacheManager, _) => UserDetailsRepository(apiClient, cacheManager),
        ),
        ProxyProvider2<ApiClient, CacheManager, MealsRepository>(
          update: (_, apiClient, cacheManager, _) => MealsRepository(apiClient, cacheManager),
        ),
        ProxyProvider2<ApiClient, CacheManager, DietGenerationRepository>(
          update: (_, apiClient, cacheManager, _) => DietGenerationRepository(apiClient, cacheManager),
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
                (context) => DailySummaryBloc(context.read<DietGenerationRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    MacrosChangeBloc(context.read<UserDetailsRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    UserStatisticsBloc(context.read<UserDetailsRepository>()),
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
              builder: (context, child) {
                return BlocListener<DailySummaryBloc, DailySummaryState>(
                  listenWhen: (previous, current) =>
                  previous.getNotification != current.getNotification &&
                      current.getNotification != null,
                  listener: (context, state) {
                    final notification = state.getNotification!(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(notification.message),
                        backgroundColor: notification.isError
                            ? Colors.red
                            : Colors.green,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  child: child!,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
