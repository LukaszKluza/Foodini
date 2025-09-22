import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/models/user/user_response.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/views/screens/main_page_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../wrapper/test_wrapper_builder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

    UserStorage().setUser(
      UserResponse(
        id: 1,
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
    expect(find.text('My Account'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('Diet preferences'), findsOneWidget);
    expect(find.byIcon(Icons.food_bank_rounded), findsOneWidget);
    expect(find.text('Change calories prediction'), findsOneWidget);
    expect(find.byIcon(Icons.change_circle_outlined), findsOneWidget);
    expect(find.text('Button 4'), findsOneWidget);
    expect(find.byIcon(Icons.do_not_disturb), findsOneWidget);

    expect(find.text('Foodini'), findsOneWidget);
  });

  testWidgets('Tap on My Account navigates to account screen', (tester) async {
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
    // Given, When
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

    // Then
    await tester.pumpAndSettle();
    await tester.tap(find.text('Diet preferences'));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('profile_details')), findsOneWidget);
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
    await tester.tap(find.text('Change calories prediction'));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('calories_result')), findsOneWidget);
  });
}
