import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/models/user/user_response.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'package:frontend/views/screens/main_page_screen.dart';

import '../../wrapper/test_wrapper_builder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestWidget(
    Widget child, {
    List<GoRoute> additionalRoutes = const [],
    String initialLocation = '/main-page',
  }) {
    return TestWrapperBuilder(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, __) => child,
          ),
        )
        .withRouter()
        .addRoutes(additionalRoutes)
        .setInitialLocation(initialLocation)
        .build();
  }

  testWidgets('Main page shows all buttons', (tester) async {
    // Given, When
    UserStorage().setUser(
      UserResponse(
        id: 1,
        name: 'Jan',
        language: Language.en,
        email: 'jan4@example.com',
      ),
    );
    await tester.pumpWidget(buildTestWidget(MainPageScreen()));

    // Then
    expect(find.text('My Account'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('Foodini'), findsOneWidget);
  });

  testWidgets('Tap on My Account navigates to account screen', (tester) async {
    // Given, When
    UserStorage().setUser(
      UserResponse(
        id: 1,
        name: 'Jan',
        language: Language.en,
        email: 'jan4@example.com',
      ),
    );
    await tester.pumpWidget(
      buildTestWidget(
        MainPageScreen(),
        additionalRoutes: [
          GoRoute(
            path: '/account',
            builder: (context, state) => const Scaffold(key: Key('my_account')),
          ),
        ],
      ),
    );

    // Then
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Account'));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('my_account')), findsOneWidget);
  });
}
