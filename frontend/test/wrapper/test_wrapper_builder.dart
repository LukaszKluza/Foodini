import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'default_test_providers.dart';
import 'test_wrapper_config.dart';

class TestWrapperBuilder {
  final Widget child;
  TestWrapperConfig _config;

  TestWrapperBuilder(this.child, {TestWrapperConfig? config})
    : _config = config ?? const TestWrapperConfig();

  TestWrapperBuilder withRouter() {
    _config = _config.copyWith(useRouter: true);
    return this;
  }

  TestWrapperBuilder addProvider(SingleChildWidget provider) {
    _config = _config.copyWith(providers: [..._config.providers, provider]);
    return this;
  }

  TestWrapperBuilder addProviders(List<SingleChildWidget> providers) {
    _config = _config.copyWith(providers: [..._config.providers, ...providers]);
    return this;
  }

  TestWrapperBuilder addRoute(GoRoute route) {
    _config = _config.copyWith(routes: [..._config.routes, route]);
    return this;
  }

  TestWrapperBuilder addRoutes(List<GoRoute> routes) {
    _config = _config.copyWith(routes: [..._config.routes, ...routes]);
    return this;
  }

  TestWrapperBuilder setInitialLocation(String initialLocation) {
    _config = _config.copyWith(initialRoute: initialLocation);
    return this;
  }

  Widget build() {
    final providers = [...getDefaultTestProviders(), ..._config.providers];

    final screenUtilWrapper = ScreenUtilInit(
      designSize: const Size(1170, 2532),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => child,
    );

    if (_config.useRouter) {
      final router = GoRouter(
        initialLocation: _config.initialRoute,
        routes: [
          GoRoute(
            path: _config.initialRoute,
            builder: (_, _) => screenUtilWrapper,
          ),
          ..._config.routes,
        ],
        errorBuilder: (context, state) => screenUtilWrapper,
      );

      return MultiProvider(
        providers: providers,
        child: MaterialApp.router(
          routerConfig: router,
          locale: _config.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
    } else {
      return MultiProvider(
        providers: providers,
        child: MaterialApp(
          home: screenUtilWrapper,
          locale: _config.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
    }
  }
}
