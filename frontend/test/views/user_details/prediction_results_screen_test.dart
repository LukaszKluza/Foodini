// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:frontend/blocs/user_details/macros_change_bloc.dart';
// import 'package:frontend/events/user_details/macros_change_events.dart';
// import 'package:frontend/models/user_details/predicted_calories.dart';
// import 'package:frontend/models/user_details/macros.dart';
// import 'package:frontend/states/macros_change_states.dart';
// import 'package:frontend/views/screens/user_details/prediction_results_screen.dart';
//
// import '../../mocks/mocks.mocks.dart';
// import '../../wrapper/test_wrapper_builder.dart';
//
// MockUserDetailsRepository mockUserDetailsRepository =
//     MockUserDetailsRepository();
//
// class RecordingMacrosChangeBloc extends MacrosChangeBloc {
//   final List<MacrosChangeEvent> recorded = [];
//
//   RecordingMacrosChangeBloc(super.repository) : super();
//
//   @override
//   void add(MacrosChangeEvent event) {
//     recorded.add(event);
//     super.add(event);
//   }
//
//   void setStateForTest(MacrosChangeState state) => super.emit(state);
// }
//
// void main() {
//   late RecordingMacrosChangeBloc macrosChangeBloc;
//   late PredictedCalories predictedCalories;
//
//   Widget buildTestWidget(
//     Widget child, {
//     String initialLocation = '/prediction-results',
//   }) {
//     return TestWrapperBuilder(child)
//         .withRouter()
//         .addProvider(
//           BlocProvider<MacrosChangeBloc>.value(value: macrosChangeBloc),
//         )
//         .setInitialLocation(initialLocation)
//         .build();
//   }
//
//   setUp(() {
//     macrosChangeBloc = RecordingMacrosChangeBloc(mockUserDetailsRepository);
//
//     predictedCalories = PredictedCalories(
//       targetCalories: 2200,
//       bmr: 1600,
//       tdee: 2100,
//       dietDurationDays: 30,
//       predictedMacros: Macros(protein: 120, fat: 70, carbs: 250),
//     );
//   });
//
//   tearDown(() {
//     macrosChangeBloc.close();
//   });
//
//   testWidgets('Basic prediction results elements are displayed', (
//     tester,
//   ) async {
//     await tester.pumpWidget(
//       buildTestWidget(
//         PredictionResultsScreen(predictedCalories: predictedCalories),
//       ),
//     );
//     await tester.pumpAndSettle();
//
//     expect(find.textContaining('2200'), findsOneWidget); // target calories
//     expect(find.textContaining('1600'), findsOneWidget); // BMR
//     expect(find.textContaining('2100'), findsOneWidget); // TDEE
//     expect(find.textContaining('30'), findsOneWidget); // Diet duration
//     expect(find.textContaining('Protein'), findsOneWidget);
//     expect(find.textContaining('Fat'), findsOneWidget);
//     expect(find.textContaining('Carbs'), findsOneWidget);
//   });
//
//   testWidgets('Protein, Fat, Carbs fields show initial values', (tester) async {
//     await tester.pumpWidget(
//       buildTestWidget(
//         PredictionResultsScreen(predictedCalories: predictedCalories),
//       ),
//     );
//     await tester.pumpAndSettle();
//
//     expect(find.widgetWithText(TextFormField, '120'), findsOneWidget);
//     expect(find.widgetWithText(TextFormField, '70'), findsOneWidget);
//     expect(find.widgetWithText(TextFormField, '250'), findsOneWidget);
//   });
//
//   testWidgets('Editing macros triggers UpdateProtein event', (tester) async {
//     await tester.pumpWidget(
//       buildTestWidget(
//         PredictionResultsScreen(predictedCalories: predictedCalories),
//       ),
//     );
//     await tester.pumpAndSettle();
//
//     // When: enter new value for protein (initial was '120')
//     final proteinFieldFinder = find.widgetWithText(TextFormField, '120');
//     expect(
//       proteinFieldFinder,
//       findsOneWidget,
//       reason: 'expected protein field with initial 120',
//     );
//     await tester.enterText(proteinFieldFinder, '130');
//     await tester.pumpAndSettle();
//
//     // Then: Recording bloc should have recorded an UpdateProtein with protein == 130
//     final hasUpdate130 = macrosChangeBloc.recorded
//         .whereType<UpdateProtein>()
//         .any((e) => e.protein == 130);
//     expect(
//       hasUpdate130,
//       isTrue,
//       reason: 'expected an UpdateProtein event with protein == 130',
//     );
//   });
//
//   testWidgets('Editing fat triggers UpdateFat event', (tester) async {
//     // Given
//     await tester.pumpWidget(
//       buildTestWidget(
//         PredictionResultsScreen(predictedCalories: predictedCalories),
//       ),
//     );
//     await tester.pumpAndSettle();
//
//     // Find the fat field using its initial value.
//     final fatFieldFinder = find.widgetWithText(TextFormField, '70');
//     expect(
//       fatFieldFinder,
//       findsOneWidget,
//       reason: 'expected fat field with initial 70',
//     );
//
//     // When
//     await tester.enterText(fatFieldFinder, '85');
//     await tester.pumpAndSettle();
//
//     // Then
//     // The RecordingBloc should have recorded an UpdateFat event with fat == 85.
//     final hasUpdate85 = macrosChangeBloc.recorded.whereType<UpdateFat>().any(
//       (e) => e.fat == 85,
//     );
//
//     expect(
//       hasUpdate85,
//       isTrue,
//       reason: 'expected an UpdateFat event with fat == 85',
//     );
//   });
//
//   testWidgets('Editing carbs triggers UpdateCarbs event', (tester) async {
//     // Given
//     await tester.pumpWidget(
//       buildTestWidget(
//         PredictionResultsScreen(predictedCalories: predictedCalories),
//       ),
//     );
//     await tester.pumpAndSettle();
//
//     // Find the carbs field using its initial value.
//     final carbsFieldFinder = find.widgetWithText(TextFormField, '250');
//     expect(
//       carbsFieldFinder,
//       findsOneWidget,
//       reason: 'expected carbs field with initial 250',
//     );
//
//     // When
//     await tester.enterText(carbsFieldFinder, '260');
//     await tester.pumpAndSettle();
//
//     // Then
//     // The RecordingBloc should have recorded an UpdateCarbs event with carbs == 260.
//     final hasUpdate260 = macrosChangeBloc.recorded.whereType<UpdateCarbs>().any(
//       (e) => e.carbs == 260,
//     );
//
//     expect(
//       hasUpdate260,
//       isTrue,
//       reason: 'expected an UpdateCarbs event with carbs == 260',
//     );
//   });
//
//   testWidgets('Save button is displayed', (tester) async {
//     await tester.pumpWidget(
//       buildTestWidget(
//         PredictionResultsScreen(predictedCalories: predictedCalories),
//       ),
//     );
//
//     await tester.pumpAndSettle();
//
//     final saveButton = tester.allWidgets.firstWhere(
//       (widget) => widget.key == const Key('save_predicted_calories_button'),
//     );
//
//     expect(saveButton, isNotNull);
//   });
//
//   testWidgets(
//     'Shows validation error when total calories are out of tolerance',
//     (WidgetTester tester) async {
//       await tester.pumpWidget(
//         buildTestWidget(
//           PredictionResultsScreen(predictedCalories: predictedCalories),
//         ),
//       );
//
//       await tester.pumpAndSettle();
//
//       final proteinField = find.byType(TextFormField).first;
//       await tester.enterText(proteinField, '1000');
//
//       final form = find.byType(Form);
//       FormState formState = tester.firstState(form) as FormState;
//       final isValid = formState.validate();
//
//       expect(isValid, isFalse);
//     },
//   );
// }
