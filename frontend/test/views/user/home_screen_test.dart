import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/views/screens/user/home_screen.dart';

import '../../wrapper/test_wrapper_builder.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return TestWrapperBuilder(child).build();
  }

  testWidgets('Home screen elements are displayed', (
    WidgetTester tester,
  ) async {
    // Given, When
    await tester.pumpWidget(buildTestWidget(HomeScreen()));
    await tester.pumpAndSettle();

    // Then
    expect(find.byType(ElevatedButton), findsNWidgets(2));
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.byIcon(Icons.translate_rounded), findsOneWidget);
  });
}
