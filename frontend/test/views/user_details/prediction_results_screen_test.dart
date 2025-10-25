import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/blocs/user_details/macros_change_bloc.dart';
import 'package:frontend/models/processing_status.dart';
import 'package:frontend/models/user_details/macros.dart';
import 'package:frontend/models/user_details/predicted_calories.dart';
import 'package:frontend/states/macros_change_states.dart';
import 'package:frontend/views/screens/user_details/prediction_results_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../wrapper/test_wrapper_builder.dart';

class MockMacrosChangeBloc extends Mock implements MacrosChangeBloc {}

void main() {
  late MockMacrosChangeBloc mockMacrosChangeBloc;
  late PredictedCalories predictedCalories;

  Widget buildTestWidget(
    Widget child, {
    String initialLocation = '/prediction-results',
  }) {
    return TestWrapperBuilder(child)
        .withRouter()
        .addProvider(
          BlocProvider<MacrosChangeBloc>.value(value: mockMacrosChangeBloc),
        )
        .setInitialLocation(initialLocation)
        .build();
  }

  setUp(() {
    mockMacrosChangeBloc = MockMacrosChangeBloc();

    predictedCalories = PredictedCalories(
      targetCalories: 2200,
      bmr: 1600,
      tdee: 2100,
      dietDurationDays: 30,
      predictedMacros: Macros(protein: 120, fat: 70, carbs: 250),
    );
  });

  testWidgets('Prediction results screen, happy path.', (tester) async {
    // Given
    final testState = MacrosChangeState(
      processingStatus: ProcessingStatus.gettingSuccess,
      predictedCalories: predictedCalories
    );

    when(() => mockMacrosChangeBloc.state).thenReturn(testState);

    whenListen(
      mockMacrosChangeBloc,
      Stream<MacrosChangeState>.fromIterable([testState]),
      initialState: testState,
    );

    // When
    await tester.pumpWidget(
      buildTestWidget(
        BlocProvider<MacrosChangeBloc>.value(
          value: mockMacrosChangeBloc,
          child: PredictionResultsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Then
    expect(find.textContaining('Calories prediction'), findsOneWidget); // title
    expect(find.textContaining('2200'), findsOneWidget); // target calories
    expect(find.textContaining('1600'), findsOneWidget); // BMR
    expect(find.textContaining('2100'), findsOneWidget); // TDEE
    expect(find.textContaining('30'), findsOneWidget); // Diet duration
    expect(find.textContaining('Protein'), findsOneWidget);
    expect(find.textContaining('Fat'), findsOneWidget);
    expect(find.textContaining('Carbs'), findsOneWidget);

    await tester.drag(find.byType(ListView), Offset(0, -100));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('save_predicted_calories_button')), findsOneWidget);
    expect(find.byKey(Key('redirect_to_profile_details_button')), findsNothing);
    expect(find.byKey(Key('refresh_request_button')), findsNothing);
  });

  testWidgets('Prediction results screen, prediction result not found.', (tester) async {
    // Given
    final testState = MacrosChangeState(
        getMessage: (_) => 'Error message from backend',
        errorCode: 404,
        processingStatus: ProcessingStatus.gettingFailure
    );

    when(() => mockMacrosChangeBloc.state).thenReturn(testState);

    whenListen(
      mockMacrosChangeBloc,
      Stream<MacrosChangeState>.fromIterable([testState]),
      initialState: testState,
    );

    // When
    await tester.pumpWidget(
      buildTestWidget(
        BlocProvider<MacrosChangeBloc>.value(
          value: mockMacrosChangeBloc,
          child: PredictionResultsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Then
    expect(find.textContaining('Calories prediction'), findsOneWidget); // title
    expect(find.textContaining('Error message from backend'), findsOneWidget);

    expect(find.byIcon(Icons.warning_amber), findsOneWidget);

    expect(find.byKey(Key('save_predicted_calories_button')), findsNothing);
    expect(find.byKey(Key('redirect_to_profile_details_button')), findsOneWidget);
    expect(find.byKey(Key('refresh_request_button')), findsNothing);
  });

  testWidgets('Prediction results screen, error code other than 404.', (tester) async {
    // Given
    final testState = MacrosChangeState(
        getMessage: (_) => 'Error message from backend',
        errorCode: 400,
        processingStatus: ProcessingStatus.gettingFailure
    );

    when(() => mockMacrosChangeBloc.state).thenReturn(testState);

    whenListen(
      mockMacrosChangeBloc,
      Stream<MacrosChangeState>.fromIterable([testState]),
      initialState: testState,
    );

    // When
    await tester.pumpWidget(
      buildTestWidget(
        BlocProvider<MacrosChangeBloc>.value(
          value: mockMacrosChangeBloc,
          child: PredictionResultsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Then
    expect(find.textContaining('Calories prediction'), findsOneWidget); // title
    expect(find.textContaining('Error message from backend'), findsOneWidget);

    expect(find.byIcon(Icons.warning_amber), findsOneWidget);

    expect(find.byKey(Key('save_predicted_calories_button')), findsNothing);
    expect(find.byKey(Key('redirect_to_profile_details_button')), findsNothing);
    expect(find.byKey(Key('refresh_request_button')), findsOneWidget);
  });

  testWidgets(
    'Shows validation error when total calories are out of tolerance',
    (WidgetTester tester) async {
      // Given
      final testState = MacrosChangeState(
          processingStatus: ProcessingStatus.gettingSuccess,
          predictedCalories: predictedCalories
      );

      when(() => mockMacrosChangeBloc.state).thenReturn(testState);

      whenListen(
        mockMacrosChangeBloc,
        Stream<MacrosChangeState>.fromIterable([testState]),
        initialState: testState,
      );

      // When
      await tester.pumpWidget(
        buildTestWidget(
          BlocProvider<MacrosChangeBloc>.value(
            value: mockMacrosChangeBloc,
            child: PredictionResultsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final proteinField = find.byType(TextFormField).first;
      await tester.enterText(proteinField, '1000');

      final form = find.byType(Form);
      FormState formState = tester.firstState(form) as FormState;
      final isValid = formState.validate();

      expect(isValid, isFalse);
    },
  );
}
