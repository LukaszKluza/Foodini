import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/single_child_widget.dart';

class TestWrapperConfig {
  final List<SingleChildWidget> providers;
  final bool useRouter;
  final Locale locale;
  final List<GoRoute> routes;
  final String initialRoute;

  const TestWrapperConfig({
    this.providers = const [],
    this.useRouter = false,
    this.locale = const Locale('en'),
    this.routes = const [],
    this.initialRoute = '/',
  });

  TestWrapperConfig copyWith({
    List<SingleChildWidget>? providers,
    bool? useRouter,
    Locale? locale,
    List<GoRoute>? routes,
    String? initialRoute,
  }) {
    return TestWrapperConfig(
      providers: providers ?? this.providers,
      useRouter: useRouter ?? this.useRouter,
      locale: locale ?? this.locale,
      routes: routes ?? this.routes,
      initialRoute: initialRoute ?? this.initialRoute,
    );
  }
}
