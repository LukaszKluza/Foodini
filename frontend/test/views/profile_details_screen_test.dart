import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/assets/profile_details/gender.pbenum.dart';
import 'package:frontend/blocs/diet_form_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/views/screens/profile_details_screen.dart';
import 'package:intl/intl.dart';

void main() {

  final bloc = DietFormBloc();

  testWidgets('Profile details screen elements are displayed', (
    WidgetTester tester,
  ) async {
    // Given, When
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DietFormBloc>.value(
          value: bloc,
          child: const ProfileDetailsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Then
    expect(find.byKey(Key(AppConfig.gender)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.height)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.weight)), findsOneWidget);
    expect(find.byKey(Key(AppConfig.dateOfBirth)), findsOneWidget);
  });

  testWidgets('Gender enums are displayed after tap', (
    WidgetTester tester,
  ) async {
    // Given
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DietFormBloc>.value(
          value: bloc,
          child: const ProfileDetailsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byKey(Key(AppConfig.gender)));
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.genderLabels[Gender.MALE]!), findsOneWidget);
    expect(find.text(AppConfig.genderLabels[Gender.FEMALE]!), findsOneWidget);

    await tester.tap(find.text(AppConfig.genderLabels[Gender.FEMALE]!));
    await tester.pumpAndSettle();

    expect(find.text(AppConfig.genderLabels[Gender.FEMALE]!), findsOneWidget);
  });

  testWidgets('Height slider works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DietFormBloc>.value(
          value: bloc,
          child: const ProfileDetailsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // // When
    final sliderFinder = find.byKey(Key(AppConfig.height));

    await tester.drag(sliderFinder, const Offset(15, 0));
    await tester.pumpAndSettle();

    // Then
    expect(find.textContaining('145'), findsOneWidget);
  });

  testWidgets('Weight slider works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DietFormBloc>.value(
          value: bloc,
          child: const ProfileDetailsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // // When
    final sliderFinder = find.byKey(Key(AppConfig.weight));

    await tester.drag(sliderFinder, const Offset(15, 0));
    await tester.pumpAndSettle();

    // Then
    expect(find.textContaining('90'), findsOneWidget);
  });

  testWidgets('Height pop-up works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DietFormBloc>.value(
          value: bloc,
          child: const ProfileDetailsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // // When
    await tester.tap(find.textContaining(AppConfig.height));
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.enterYourHeight), findsOneWidget);
    expect(find.textContaining(AppConfig.heightCm), findsOneWidget);
    expect(find.text(AppConfig.ok), findsOneWidget);
    expect(find.text(AppConfig.cancel), findsOneWidget);

    await tester.enterText(find.byKey(Key(AppConfig.heightCm)), '177');

    await tester.tap(find.textContaining(AppConfig.ok));
    await tester.pumpAndSettle();

    expect(find.textContaining('177'), findsOneWidget);
  });

  testWidgets('Weight pop-up works properly', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DietFormBloc>.value(
          value: bloc,
          child: const ProfileDetailsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // // When
    await tester.tap(find.textContaining(AppConfig.weight));
    await tester.pumpAndSettle();

    // Then
    expect(find.text(AppConfig.enterYourWeight), findsOneWidget);
    expect(find.textContaining(AppConfig.weightKg), findsOneWidget);
    expect(find.text(AppConfig.ok), findsOneWidget);
    expect(find.text(AppConfig.cancel), findsOneWidget);

    await tester.enterText(find.byKey(Key(AppConfig.weightKg)), '77');

    await tester.tap(find.textContaining(AppConfig.ok));
    await tester.pumpAndSettle();

    expect(find.textContaining('77'), findsOneWidget);
  });

  testWidgets('Date picker appears on tap', (WidgetTester tester) async {
    // Given
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DietFormBloc>.value(
          value: bloc,
          child: const ProfileDetailsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // When
    final dateField = find.byKey(Key(AppConfig.dateOfBirth));
    expect(dateField, findsOneWidget);

    await tester.tap(dateField);
    await tester.pumpAndSettle();

    // Then
    expect(find.byType(CalendarDatePicker), findsOneWidget);
  });
}
