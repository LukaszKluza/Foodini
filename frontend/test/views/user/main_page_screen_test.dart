import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/models/user/user_response.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'package:frontend/views/screens/main_page_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Main page shows all buttons', (tester) async {
    UserStorage().setUser(
      UserResponse(id: 1, name: "Jan", language: Language.en, email: 'jan4@example.com'),
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: MainPageScreen(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );

    expect(find.text('My Account'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('Hey'), findsOneWidget);
    expect(find.text('Jan'), findsOneWidget);
  });

  testWidgets('Tap on My Account navigates to account screen', (tester) async {
    final goRouter = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => MainPageScreen()),
        GoRoute(
          path: '/account',
          builder: (context, state) => const Scaffold(key: Key('my_account')),
        ),
      ],
    );

    UserStorage().setUser(
      UserResponse(id: 1, name: "Jan", language: Language.en, email: 'jan4@example.com'),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: goRouter,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('My Account'));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('my_account')), findsOneWidget);
  });
}
