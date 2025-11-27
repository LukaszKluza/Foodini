import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

import '../wrapper/test_wrapper_builder.dart';

void main() {
  Widget buildTestWidget(
    Widget child, {
    List<GoRoute> additionalRoutes = const [],
    String initialLocation = '/',
  }) {
    return TestWrapperBuilder(child)
        .withRouter()
        .addRoutes(additionalRoutes)
        .setInitialLocation(initialLocation)
        .build();
  }

  group('BottomNavBar Widget Tests', () {
    testWidgets('renders all three buttons', (tester) async {
      // When
      await tester.pumpWidget(
        buildTestWidget(
          Scaffold(
            bottomNavigationBar: const BottomNavBar(currentRoute: '/profile'),
          ),
        ),
      );

      // Then
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('Home button navigates to /main_page', (tester) async {
      await tester.pumpWidget(
        // When
        buildTestWidget(
          Scaffold(
            body: const Text('Profile'),
            bottomNavigationBar: const BottomNavBar(currentRoute: '/profile'),
          ),
          additionalRoutes: [
            GoRoute(
              path: '/main-page',
              builder: (_, _) => const Scaffold(body: Text('Main Page')),
            ),
          ],
          initialLocation: '/profile',
        ),
      );
      await tester.pumpAndSettle();

      // Then
      expect(find.text('Profile'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Main Page'), findsOneWidget);
    });

    testWidgets('Back button triggers pop in normal mode if possible', (
      tester,
    ) async {
      // When
      await tester.pumpWidget(
        buildTestWidget(
          Scaffold(
            body: Builder(
              builder:
                  (context) => Center(
                    child: ElevatedButton(
                      child: const Text('Go to Page 2'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => Scaffold(
                                  appBar: AppBar(title: const Text('Page 2')),
                                  bottomNavigationBar: const BottomNavBar(
                                    currentRoute: '/page2',
                                  ),
                                  body: const Text('Page 2 Content'),
                                ),
                          ),
                        );
                      },
                    ),
                  ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go to Page 2'));
      await tester.pumpAndSettle();

      // Then
      expect(find.text('Page 2 Content'), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate((widget) {
          return widget is Icon &&
              widget.icon == Icons.arrow_back_rounded;
        }),
      );

      await tester.pumpAndSettle();

      expect(find.text('Go to Page 2'), findsOneWidget);
    });

    testWidgets('Next button navigates to nextRoute in wizard mode', (
      tester,
    ) async {
      // When
      await tester.pumpWidget(
        buildTestWidget(
          Scaffold(
            body: Column(
              children: const [
                Text('Wizard Step 1'),
                BottomNavBar(
                  currentRoute: '/wizard1',
                  mode: NavBarMode.wizard,
                  nextRoute: '/wizard2',
                ),
              ],
            ),
          ),
          additionalRoutes: [
            GoRoute(
              path: '/wizard2',
              builder: (_, _) => const Scaffold(body: Text('Wizard Step 2')),
            ),
          ],
          initialLocation: '/wizard1',
        ),
      );
      await tester.pumpAndSettle();

      // Then
      expect(find.text('Wizard Step 1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Wizard Step 2'), findsOneWidget);
    });

    testWidgets('Back button navigates to prevRoute in wizard mode', (
      tester,
    ) async {
      // When
      await tester.pumpWidget(
        buildTestWidget(
          Scaffold(
            body: Column(
              children: const [
                Text('Wizard Step 2'),
                BottomNavBar(
                  currentRoute: '/wizard2',
                  mode: NavBarMode.wizard,
                  prevRoute: '/wizard1',
                ),
              ],
            ),
          ),
          additionalRoutes: [
            GoRoute(
              path: '/wizard1',
              builder: (_, _) => const Scaffold(body: Text('Wizard Step 1')),
            ),
          ],
          initialLocation: '/wizard2',
        ),
      );
      await tester.pumpAndSettle();

      // Then
      expect(find.text('Wizard Step 2'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Wizard Step 1'), findsOneWidget);
    });
  });
}
