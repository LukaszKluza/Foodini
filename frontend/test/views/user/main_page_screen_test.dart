import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/models/user/user_response.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/views/screens/main_page_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid_value.dart';

import '../../wrapper/test_wrapper_builder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late UuidValue uuidUserId;

  Widget buildTestWidget(
    Widget child, {
    List<GoRoute> additionalRoutes = const [],
    String initialLocation = '/main-page',
  }) {
    return TestWrapperBuilder(child)
        .withRouter()
        .addRoutes(additionalRoutes)
        .setInitialLocation(initialLocation)
        .build();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    uuidUserId = UuidValue.fromString('c4b678c3-bb44-5b37-90d9-5b0c9a4f1b87');

    UserStorage().setUser(
      UserResponse(
        id: uuidUserId,
        name: 'Jan',
        language: Language.en,
        email: 'jan4@example.com',
      ),
    );
  });

  testWidgets('Main page shows all buttons', (tester) async {
    // Given, When
    await tester.pumpWidget(buildTestWidget(MainPageScreen()));
    // Then
    expect(find.text('Daily Summary'), findsOneWidget);
    expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
    expect(find.text('Daily Menu'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    expect(find.text('Diet Preferences'), findsOneWidget);
    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    expect(find.text('Change Calories Prediction'), findsOneWidget);
    expect(find.byIcon(Icons.auto_graph), findsOneWidget);
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.byIcon(Icons.query_stats_rounded), findsOneWidget);
    expect(find.text('My Account'), findsOneWidget);
    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
  });

  testWidgets('Tap on My Account navigates to account screen', (tester) async {
    tester.view.devicePixelRatio = 1.5;

    // Given, When
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

  testWidgets('Tap on Diet preferences navigates to account screen', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        MainPageScreen(),
        additionalRoutes: [
          GoRoute(
            path: '/profile-details',
            builder: (context, state) => const Scaffold(key: Key('profile_details')),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    final dietPreferencesFinder = find.text('Diet Preferences');
    await tester.ensureVisible(dietPreferencesFinder);
    await tester.tap(dietPreferencesFinder);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile_details')), findsOneWidget);
  });


  testWidgets('Tap on Change calories prediction, navigates to prediction result screen', (tester) async {
    // Given, When
    await tester.pumpWidget(
      buildTestWidget(
        MainPageScreen(),
        additionalRoutes: [
          GoRoute(
            path: '/calories-result',
            builder: (context, state) => const Scaffold(key: Key('calories_result')),
          ),
        ],
      ),
    );

    // Then
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change Calories Prediction'));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('calories_result')), findsOneWidget);
  });
}
