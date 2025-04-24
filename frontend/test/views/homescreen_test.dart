import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/views/screens/home_screen.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home screen elements are displayed', (WidgetTester tester) async {
    // Given, When
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Then
    expect(find.byType(ElevatedButton), findsNWidgets(2));
    expect(find.text('Login'), findsNWidgets(1));
    expect(find.text('Register'), findsNWidgets(1));
    expect(find.text('Welcome in Foodini'), findsNWidgets(1));
  });
}
