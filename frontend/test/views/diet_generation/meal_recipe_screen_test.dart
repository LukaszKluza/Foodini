import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/api_exception.dart';
import 'package:frontend/blocs/diet_generation/meal_recipe_bloc.dart';
import 'package:frontend/models/diet_generation/ingredient.dart';
import 'package:frontend/models/diet_generation/ingredients.dart';
import 'package:frontend/models/diet_generation/meal_icon_info.dart';
import 'package:frontend/models/diet_generation/meal_recipe.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/models/diet_generation/step.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/models/user/user_response.dart';
import 'package:frontend/repository/diet_prediction/meal_recipe_repository.dart';
import 'package:frontend/repository/user/user_storage.dart';
import 'package:frontend/views/screens/diet_generation/meal_recipe_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../mocks/mocks.mocks.dart';
import '../../wrapper/test_wrapper_builder.dart';

MockMealRecipeRepository mockMealRecipeRepository = MockMealRecipeRepository();

void main() {
  late MealRecipeBloc mealRecipeBloc;
  late MealRecipe mealRecipe;
  late MealIconInfo mealIconInfo;

  Widget buildTestWidget(
    Widget child, {
    String initialLocation = '/meal-recipe/1/EN',
  }) {
    return TestWrapperBuilder(child)
        .withRouter()
        .addProvider(BlocProvider<MealRecipeBloc>.value(value: mealRecipeBloc))
        .addProvider(
          Provider<MealRecipeRepository>.value(value: mockMealRecipeRepository),
        )
        .setInitialLocation(initialLocation)
        .build();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mealRecipeBloc = MealRecipeBloc(mockMealRecipeRepository);

    mealRecipe = MealRecipe(
      id: 1,
      mealRecipeId: 1,
      language: Language.en,
      mealName: 'Cornflakes with soy milk',
      mealType: MealType.breakfast,
      mealDescription: 'Cornflakes with soy milk; Meal description',
      iconId: 1,
      ingredients: Ingredients(
        ingredients: [
          Ingredient(volume: 1, unit: 'cup', name: 'Soy milk', optionalNote: 'cold or warm, as preferred'),
          Ingredient(volume: 1, unit: 'cup', name: 'Cornflakes'),
          Ingredient(volume: 1, unit: 'spoon', name: 'Sugar'),
        ],
        foodAdditives: 'Honey, fruits',
      ),
      steps: [
        MealRecipeStep(
          description: 'Pour the cornflakes into a bowl.',
          optional: false,
        ),
        MealRecipeStep(
          description: 'Add the milk over the cornflakes.',
          optional: false,
        ),
        MealRecipeStep(
          description: 'Sweeten with sugar or honey.',
          optional: true,
        ),
        MealRecipeStep(
          description: 'Top with sliced fruits or nuts.',
          optional: true,
        ),
        MealRecipeStep(
          description: 'Serve immediately before it gets soggy.',
          optional: false,
        ),
      ],
    );

    mealIconInfo = MealIconInfo(
      id: 1,
      mealType: MealType.breakfast,
      iconPath: '/black-coffee-fried-egg-with-toasts.jpg',
    );

    UserStorage().setUser(
      UserResponse(
        id: 1,
        name: 'Jan',
        language: Language.en,
        email: 'jan4@example.com',
      ),
    );
  });

  tearDown(() {
    mealRecipeBloc.close();
  });

  testWidgets('Meal recipe screen elements are displayed', (
    WidgetTester tester,
  ) async {
    // Given
    when(
      mockMealRecipeRepository.getMealRecipe(1, 1, Language.en),
    ).thenAnswer((_) async => mealRecipe);

    when(
      mockMealRecipeRepository.getMealIconInfo(1, MealType.breakfast),
    ).thenAnswer((_) async => mealIconInfo);

    // When
    await tester.pumpWidget(
      buildTestWidget(const MealRecipeScreen(mealId: 1)),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Then
    expect(find.byKey(const Key('bloc_1_EN')), findsOneWidget);
    expect(find.byKey(const Key('body_1_EN')), findsOneWidget);
    expect(find.text('Cornflakes with soy milk'), findsOneWidget);
    expect(find.text('Meal description'), findsOneWidget);
    expect(find.text('Cornflakes with soy milk; Meal description'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('• 1.0 cup Soy milk (cold or warm, as preferred)'), findsOneWidget);
    expect(find.text('• 1.0 cup Cornflakes'), findsOneWidget);
    expect(find.text('• 1.0 spoon Sugar'), findsOneWidget);
    expect(find.text('Optional: Honey, fruits'), findsOneWidget);
    expect(find.text('Recipe'), findsOneWidget);
    expect(find.text('1. Pour the cornflakes into a bowl.'), findsOneWidget);
    expect(find.text('2. Add the milk over the cornflakes.'), findsOneWidget);
    expect(find.text('3. (Optional) Sweeten with sugar or honey.'), findsOneWidget);
    expect(find.text('4. (Optional) Top with sliced fruits or nuts.'), findsOneWidget);
    expect(find.text('5. Serve immediately before it gets soggy.'), findsOneWidget);

    expect(find.byKey(const Key('refresh_request_button')), findsNothing);
    expect(find.byKey(const Key('redirect_to_main_page_button')), findsNothing);
  });

  testWidgets('Meal recipe screen, server error', (
      WidgetTester tester,
      ) async {
    // Given
    when(
      mockMealRecipeRepository.getMealRecipe(1, 1, Language.en),
    ).thenThrow(ApiException({'detail': 'Server error'}, statusCode: 500));

    // When
    await tester.pumpWidget(
      buildTestWidget(const MealRecipeScreen(mealId: 1)),
    );
    await tester.pumpAndSettle();

    // Then
    expect(find.byKey(const Key('bloc_1_EN')), findsOneWidget);
    expect(find.byKey(const Key('body_1_EN')), findsOneWidget);
    expect(find.byKey(const Key('refresh_request_button')), findsOneWidget);

    expect(find.text('Cornflakes with soy milk'), findsNothing);
    expect(find.text('Meal description'), findsNothing);
    expect(find.text('Cornflakes with soy milk; Meal description'), findsNothing);
    expect(find.text('Groceries'), findsNothing);
    expect(find.text('• 1.0 cup Soy milk (cold or warm, as preferred)'), findsNothing);
    expect(find.text('• 1.0 cup Cornflakes'), findsNothing);
    expect(find.text('• 1.0 spoon Sugar'), findsNothing);
    expect(find.text('Optional: Honey, fruits'), findsNothing);
    expect(find.text('Recipe'), findsNothing);
    expect(find.text('1. Pour the cornflakes into a bowl.'), findsNothing);
    expect(find.text('2. Add the milk over the cornflakes.'), findsNothing);
    expect(find.text('3. (Optional) Sweeten with sugar or honey.'), findsNothing);
    expect(find.text('4. (Optional) Top with sliced fruits or nuts.'), findsNothing);
    expect(find.text('5. Serve immediately before it gets soggy.'), findsNothing);
    expect(find.byKey(const Key('redirect_to_main_page_button')), findsNothing);
  });

  testWidgets('Meal recipe screen, 404 error', (
      WidgetTester tester,
      ) async {
    // Given
    when(
      mockMealRecipeRepository.getMealRecipe(1, 1, Language.en),
    ).thenThrow(ApiException({'detail': 'Meal recipe not found'}, statusCode: 404));

    // When
    await tester.pumpWidget(
      buildTestWidget(const MealRecipeScreen(mealId: 1)),
    );
    await tester.pumpAndSettle();

    // Then
    expect(find.byKey(const Key('bloc_1_EN')), findsOneWidget);
    expect(find.byKey(const Key('body_1_EN')), findsOneWidget);
    expect(find.byKey(const Key('redirect_to_main_page_button')), findsOneWidget);
    expect(find.text('Go to main page'), findsOneWidget);
    expect(find.text('Meal recipe not found'), findsOneWidget);


    expect(find.text('Cornflakes with soy milk'), findsNothing);
    expect(find.text('Meal description'), findsNothing);
    expect(find.text('Cornflakes with soy milk; Meal description'), findsNothing);
    expect(find.text('Groceries'), findsNothing);
    expect(find.text('• 1.0 cup Soy milk (cold or warm, as preferred)'), findsNothing);
    expect(find.text('• 1.0 cup Cornflakes'), findsNothing);
    expect(find.text('• 1.0 spoon Sugar'), findsNothing);
    expect(find.text('Optional: Honey, fruits'), findsNothing);
    expect(find.text('Recipe'), findsNothing);
    expect(find.text('1. Pour the cornflakes into a bowl.'), findsNothing);
    expect(find.text('2. Add the milk over the cornflakes.'), findsNothing);
    expect(find.text('3. (Optional) Sweeten with sugar or honey.'), findsNothing);
    expect(find.text('4. (Optional) Top with sliced fruits or nuts.'), findsNothing);
    expect(find.text('5. Serve immediately before it gets soggy.'), findsNothing);
    expect(find.byKey(const Key('refresh_request_button')), findsNothing);
  });
}
