import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/blocs/user_details/macros_change_bloc.dart';
import 'package:frontend/events/user_details/macros_change_events.dart';
import 'package:frontend/models/submitting_status.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/models/user/user_response.dart';
import 'package:frontend/models/user_details/macros.dart';
import 'package:frontend/models/user_details/predicted_calories.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/states/macros_change_states.dart';
import 'package:frontend/views/screens/user_details/prediction_results_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mocks/mocks.mocks.dart';
import '../../wrapper/test_wrapper_builder.dart';

class RecordingMacrosChangeBloc extends MacrosChangeBloc {
  final List<MacrosChangeState> recorded = [];

  RecordingMacrosChangeBloc(super.repository) : super();

  @override
  void emit(MacrosChangeState state) {
    recorded.add(state);
    super.emit(state);
  }
}

late RecordingMacrosChangeBloc macrosChangeBloc;
late PredictedCalories predictedCalories;

MockUserDetailsRepository mockUserDetailsRepository =
    MockUserDetailsRepository();

void main() {
  Widget buildTestWidget(
    Widget child, {
    List<GoRoute> additionalRoutes = const [],
    String initialLocation = '/prediction-results',
  }) {
    return TestWrapperBuilder(child)
        .withRouter()
        .addProvider(
          BlocProvider<MacrosChangeBloc>.value(value: macrosChangeBloc),
        )
        .addRoutes(additionalRoutes)
        .setInitialLocation(initialLocation)
        .build();
  }

  setUp(() {
    macrosChangeBloc = RecordingMacrosChangeBloc(mockUserDetailsRepository);

    predictedCalories = PredictedCalories(
      targetCalories: 2200,
      bmr: 1600,
      tdee: 2100,
      dietDurationDays: 30,
      predictedMacros: Macros(protein: 120, fat: 70, carbs: 250),
    );

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

  tearDown(() async {
    await macrosChangeBloc.close();
  });

  testWidgets('Prediction results screen, happy path.', (tester) async {
    // Given
    when(
      mockUserDetailsRepository.getCaloriesPrediction(1),
    ).thenAnswer((_) async => predictedCalories);

    // When
    await tester.pumpWidget(
      buildTestWidget(
        BlocProvider<MacrosChangeBloc>.value(
          value: macrosChangeBloc,
          child: PredictionResultsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      while (macrosChangeBloc.recorded.length < 2) {
        await Future.delayed(Duration(milliseconds: 50));
      }
    });

    expect(macrosChangeBloc.recorded, containsAllInOrder( [
      MacrosChangeState(processingStatus: ProcessingStatus.gettingOnGoing),
      MacrosChangeState(predictedCalories: predictedCalories, processingStatus: ProcessingStatus.gettingSuccess)
    ]));
  });

  testWidgets('Prediction results screen, prediction not found.', (tester) async {
    // Given
    when(mockUserDetailsRepository.getCaloriesPrediction(1))
        .thenAnswer((_) async {
      throw ApiException({'detail': 'Prediction not found'}, statusCode: 404);
    });

    // When
    await tester.pumpWidget(
      buildTestWidget(
        BlocProvider<MacrosChangeBloc>.value(
          value: macrosChangeBloc,
          child: PredictionResultsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      while (macrosChangeBloc.recorded.length < 2) {
        await Future.delayed(Duration(milliseconds: 50));
      }
    });
    final context = tester.element(find.byType(PredictionResultsScreen));

    expect(macrosChangeBloc.recorded, containsAllInOrder( [
      MacrosChangeState(processingStatus: ProcessingStatus.gettingOnGoing),
      MacrosChangeState(errorCode: 404, processingStatus: ProcessingStatus.gettingFailure)
    ]));

    expect(macrosChangeBloc.recorded[1].getMessage!(context), 'Prediction not found');
  });

  testWidgets('Prediction results screen, server error.', (tester) async {
    // Given
    int callCount = 0;

    when(mockUserDetailsRepository.getCaloriesPrediction(1)).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) {
        throw ApiException({'detail': 'Server error'}, statusCode: 500);
      }
      return predictedCalories;
    });

    // When
    await tester.pumpWidget(
      buildTestWidget(
        BlocProvider<MacrosChangeBloc>.value(
          value: macrosChangeBloc,
          child: PredictionResultsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      while (macrosChangeBloc.recorded.length < 2) {
        await Future.delayed(Duration(milliseconds: 50));
      }
    });
    final context = tester.element(find.byType(PredictionResultsScreen));

    expect(macrosChangeBloc.recorded, containsAllInOrder( [
      MacrosChangeState(processingStatus: ProcessingStatus.gettingOnGoing),
      MacrosChangeState(errorCode: 500, processingStatus: ProcessingStatus.gettingFailure)
    ]));

    expect(macrosChangeBloc.recorded[1].getMessage!(context), 'Server error');

    // When
    macrosChangeBloc.add(LoadInitialMacros());

    // Then

    await tester.runAsync(() async {
      while (macrosChangeBloc.recorded.length < 4) {
        await Future.delayed(Duration(milliseconds: 50));
      }
    });

    expect(macrosChangeBloc.recorded, containsAllInOrder( [
      MacrosChangeState(processingStatus: ProcessingStatus.gettingOnGoing),
      MacrosChangeState(predictedCalories: predictedCalories, processingStatus: ProcessingStatus.gettingSuccess)
    ]));
  });

  testWidgets('Prediction results screen, submitting update happy path.', (tester) async {
    // Given
    var updatedMacros = Macros(protein: 110, fat: 70, carbs: 240);
    var updatedPredictedCalories = PredictedCalories(
      targetCalories: 2120,
      bmr: 1600,
      tdee: 2100,
      dietDurationDays: 30,
      predictedMacros: updatedMacros,
    );

    when(mockUserDetailsRepository.getCaloriesPrediction(1),).thenAnswer((_) async => predictedCalories);
    when(mockUserDetailsRepository.submitMacrosChange(updatedMacros, 1),).thenAnswer((_) async => updatedPredictedCalories);

    // When
    await tester.pumpWidget(
      buildTestWidget(
        BlocProvider<MacrosChangeBloc>.value(
          value: macrosChangeBloc,
          child: PredictionResultsScreen(),
        ),
        additionalRoutes:[
          GoRoute(
            path: '/main-page',
            builder: (context, state) => const Scaffold(key: Key('main_page')),
          )
        ]
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      while (macrosChangeBloc.recorded.length < 2) {
        await Future.delayed(Duration(milliseconds: 50));
      }
    });

    expect(macrosChangeBloc.recorded, containsAllInOrder( [
      MacrosChangeState(processingStatus: ProcessingStatus.gettingOnGoing),
      MacrosChangeState(predictedCalories: predictedCalories, processingStatus: ProcessingStatus.gettingSuccess),
    ]));

    // When
    macrosChangeBloc.add(SubmitMacrosChange(updatedMacros));

    // Then
    await tester.runAsync(() async {
      while (macrosChangeBloc.recorded.length < 4) {
        await Future.delayed(Duration(milliseconds: 50));
      }
    });

    expect(macrosChangeBloc.recorded, containsAllInOrder( [
      MacrosChangeState(macros:updatedMacros, predictedCalories: predictedCalories, processingStatus: ProcessingStatus.submittingOnGoing),
      MacrosChangeState(macros:updatedMacros, predictedCalories: updatedPredictedCalories, processingStatus: ProcessingStatus.submittingSuccess),
    ]));

    await tester.pumpAndSettle();
  });
}
