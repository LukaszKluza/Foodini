import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/blocs/user_details/diet_form_bloc.dart';
import 'package:frontend/views/screens/user_details/profile_details_screen.dart';

import '../../mocks/mocks.mocks.dart';
import '../../wrapper/test_wrapper_builder.dart';

MockUserDetailsRepository mockUserDetailsRepository =
    MockUserDetailsRepository();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late DietFormBloc dietFormBloc;

  Widget buildTestWidget(
    Widget child, {
    String initialLocation = '/profile-details',
  }) {
    return TestWrapperBuilder(child)
        .withRouter()
        .addProvider(BlocProvider<DietFormBloc>.value(value: dietFormBloc))
        .setInitialLocation(initialLocation)
        .build();
  }

  setUp(() {
    dietFormBloc = DietFormBloc(mockUserDetailsRepository);
  });

  tearDown(() {
    dietFormBloc.close();
  });

  testWidgets('Profile details screen elements and navbar are displayed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(const ProfileDetailsScreen()));
    await tester.pumpAndSettle();

    // Then
    expect(find.byKey(Key('gender')), findsOneWidget);
    expect(find.byKey(Key('height')), findsOneWidget);
    expect(find.byKey(Key('weight')), findsOneWidget);
    expect(find.byKey(Key('date_of_birth')), findsOneWidget);
    expect(find.byType(BottomNavBar), findsOneWidget);
  });

  testWidgets('Gender enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const ProfileDetailsScreen()));
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(Key('gender')));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Male'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);

    await tester.tap(find.text('Female'));
    await tester.pumpAndSettle();

    expect(find.text('Female'), findsOneWidget);
  });

  testWidgets('Height slider works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const ProfileDetailsScreen()));
    await tester.pumpAndSettle();

    // // When
    final sliderFinder = find.byKey(Key('height'));

    await tester.drag(sliderFinder, const Offset(15, 0));
    await tester.pumpAndSettle();

    // Then
    expect(find.textContaining('145'), findsOneWidget);
  });

  testWidgets('Weight slider works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const ProfileDetailsScreen()));
    await tester.pumpAndSettle();

    // // When
    final sliderFinder = find.byKey(Key('weight'));

    await tester.drag(sliderFinder, const Offset(15, 0));
    await tester.pumpAndSettle();

    // Then
    expect(find.textContaining('90'), findsOneWidget);
  });

  testWidgets('Height pop-up works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const ProfileDetailsScreen()));
    await tester.pumpAndSettle();

    // // When
    await tester.tap(find.textContaining('Height'));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Enter your height'), findsOneWidget);
    expect(find.textContaining('Height (cm)'), findsOneWidget);
    expect(find.text('Ok'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.enterText(find.byKey(Key('height-cm')), '177');

    await tester.tap(find.textContaining('Ok'));
    await tester.pumpAndSettle();

    expect(find.textContaining('177'), findsOneWidget);
  });

  testWidgets('Weight pop-up works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const ProfileDetailsScreen()));
    await tester.pumpAndSettle();

    // // When
    await tester.tap(find.textContaining('Weight'));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Enter your weight'), findsOneWidget);
    expect(find.textContaining('Weight (kg)'), findsOneWidget);
    expect(find.text('Ok'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.enterText(find.byKey(Key('weight_kg')), '77');

    await tester.tap(find.textContaining('Ok'));
    await tester.pumpAndSettle();

    expect(find.textContaining('77'), findsOneWidget);
  });

  testWidgets('Date picker appears on tap', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(buildTestWidget(const ProfileDetailsScreen()));
    await tester.pumpAndSettle();

    // When
    final dateField = find.byKey(Key('date_of_birth'));
    expect(dateField, findsOneWidget);

    await tester.tap(dateField);
    await tester.pumpAndSettle();

    // Then
    expect(find.byType(CalendarDatePicker), findsOneWidget);
  });
}
