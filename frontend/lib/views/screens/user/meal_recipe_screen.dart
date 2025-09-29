import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/diet_prediction/meal_recipe_bloc.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/diet_prediction/diet_prediction_events.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/repository/diet_prediction/meal_recipe_repository.dart';
import 'package:frontend/states/diet_prediction/meal_recipe.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MealRecipeScreen extends StatelessWidget {
  final int mealId;
  final Language language;

  const MealRecipeScreen({
    super.key,
    required this.mealId,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey('$mealId-${language.code}'),
      create: (_) {
        final bloc = MealRecipeBloc(
          Provider.of<MealRecipeRepository>(context, listen: false),
        );
        bloc.add(MealRecipeInit(mealId, language));
        return bloc;
      },
      child: Scaffold(
        body: _MealRecipe(key: ValueKey('$mealId-${language.code}')),
        bottomNavigationBar: BottomNavBar(
          currentRoute: GoRouterState.of(context).uri.path,
          mode: NavBarMode.normal,
        ),
      ),
    );
  }
}

class _MealRecipe extends StatelessWidget {
  const _MealRecipe({super.key});

  final TextStyle _messageStyle = Styles.errorStyle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealRecipeBloc, MealRecipeState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: ListView(
            shrinkWrap: true,
            children: [
              if (state.processingStatus!.isOngoing)
                const Center(child: CircularProgressIndicator()),

              if (state.processingStatus!.isSuccess) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tytuł nad opisem
                      Text(
                        'Meal Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Box z opisem
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.grey.shade100,
                        ),
                        child: Text(
                          state.mealRecipe!.mealDescription,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Groceries
                      Text(
                        'Groceries:',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (var ingredient in state.mealRecipe!.ingredients.ingredients)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            '• ${ingredient.name} (${ingredient.volume} ${ingredient.unit})',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Recipe steps
                      Text(
                        'Recipe:',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // for (int i = 0; i < state.mealRecipe!.steps.length; i++)
                      //   Padding(
                      //     padding: const EdgeInsets.symmetric(vertical: 2.0),
                      //     child: Text(
                      //       '${i + 1}. ${state.mealRecipe!.steps[i].description}',
                      //       style: const TextStyle(fontSize: 16),
                      //     ),
                      //   ),
                    ],
                  ),
                ),
              ],

              if (state.processingStatus!.isFailure) ...[
                // const Icon(
                //   Icons.warning_amber,
                //   color: Colors.red,
                //   size: 200.0,
                // ),
                // if (_errorCode == 404) ...[
                //   Text(
                //     AppLocalizations.of(context)!.fillFormToSeePredictions,
                //     style: TextStyle(
                //       fontSize: 30.sp.clamp(20.0, 40.0),
                //       color: Colors.orangeAccent,
                //     ),
                //   ),
                //   redirectToProfileDetailsButton(context),
                // ] else
                //   retryRequestButton(context),
              ],

              if (state.getMessage != null)
                Text(
                  state.getMessage!(context),
                  style: _messageStyle,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        );
      },
    );
  }
}
