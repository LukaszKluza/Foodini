import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/diet_generation/meal_recipe_bloc.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/diet_generation/meal_recipe_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/ingredient.dart';
import 'package:frontend/models/diet_generation/ingredients.dart';
import 'package:frontend/models/diet_generation/step.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/repository/diet_prediction/meal_recipe_repository.dart';
import 'package:frontend/states/diet_generation/meal_recipe.dart';
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
      key: ValueKey('bloc_${mealId}_${language.code}'),
      create: (_) {
        final bloc = MealRecipeBloc(
          Provider.of<MealRecipeRepository>(context, listen: false),
        );
        bloc.add(MealRecipeInit(mealId, language));
        return bloc;
      },
      child: Scaffold(
        body: _MealRecipe(key: ValueKey('body_${mealId}_${language.code}')),
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
                generateMealRecipe(state, context),
              ],

              if (state.processingStatus!.isFailure) ...[
                const Icon(Icons.warning_amber, color: Colors.red, size: 200.0),
                if (state.errorCode == 404) ...[
                  redirectToProfileDetailsButton(context),
                ] else
                  retryRequestButton(context, state),
              ],

              if (state.getErrorMessage != null)
                Text(
                  state.getErrorMessage!(context),
                  style: Styles.errorStyle,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        );
      },
    );
  }

  Padding generateMealRecipe(MealRecipeState state, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal name
          generateMealNameHeader(state),
          const SizedBox(height: 6),

          // Meal icon
          generateMealIcon(state, context),
          const SizedBox(height: 6),

          // Meal description
          generateDescriptionHeader(context),
          const SizedBox(height: 6),
          generateMealDescription(state),
          const SizedBox(height: 16),

          // Groceries
          generateGroceriesHeader(context),
          const SizedBox(height: 6),
          for (var ingredient in state.mealRecipe!.ingredients.ingredients)
            generateIngredientLine(ingredient),
          if(state.mealRecipe!.ingredients.foodAdditives != null)
            generateFoodAdditives(state.mealRecipe!.ingredients, context),
          const SizedBox(height: 16),

          // Recipe steps
          generateRecipeHeader(context),
          const SizedBox(height: 6),
          for (int i = 0; i < state.mealRecipe!.steps.length; i++)
            generateRecipeStep(state, i, context),
        ],
      ),
    );
  }

  Text generateMealNameHeader(MealRecipeState state) {
    return Text(
      state.mealRecipe!.mealName,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Text generateRecipeHeader(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.recipe,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.deepOrangeAccent,
      ),
    );
  }

  Text generateGroceriesHeader(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.groceries,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.deepOrangeAccent,
      ),
    );
  }

  Padding generateIngredientLine(Ingredient ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        getIngredientText(ingredient),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Padding generateFoodAdditives(Ingredients ingredients, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        '${AppLocalizations.of(context)!.optional}: ${ ingredients.foodAdditives!}',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Text generateDescriptionHeader(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.mealDescriptions,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Container generateMealDescription(MealRecipeState state) {
    return Container(
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
    );
  }

  Container generateMealIcon(MealRecipeState state, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),

      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: '${Endpoints.mealIcon}/${state.iconUrl!}',
        fit: BoxFit.cover,
        placeholder:
            (context, url) => SizedBox(
              height: 100,
              width: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
        errorWidget: (context, url, error) {
          CachedNetworkImage.evictFromCache('${Endpoints.mealIcon}/${state.iconUrl!}');

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber, color: Colors.red, size: 200.0),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.errorWhileFetchingMealIcon,
                style: Styles.errorStyle,
              ),
              retryRequestButton(context, state),
            ],
          );
        },

      ),
    );
  }

  Padding generateRecipeStep(
      MealRecipeState state,
      int i,
      BuildContext context,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        getStepText(state.mealRecipe!.steps[i], i, context),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  String getIngredientText(Ingredient ingredient) {
    if (ingredient.optionalNote != null) {
      return '• ${ingredient.volume} ${ingredient.unit} ${ingredient
          .name} (${ingredient.optionalNote})';
    }
    return '• ${ingredient.volume} ${ingredient.unit} ${ingredient.name}';
  }

  String getStepText(MealRecipeStep step, int idx, BuildContext context) {
    if (step.optional == true) {
      return '${idx + 1}. (${AppLocalizations.of(context)!.optional}) ${step.description}';
    }
    return '${idx + 1}. ${step.description}';
  }

  Center basicButton(
    BuildContext context,
    Key buttonKey,
    VoidCallback? onPressed,
    ButtonStyle buttonStyle,
    Widget? buttonChild,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: ElevatedButton(
          key: buttonKey,
          onPressed: () => onPressed?.call(),
          style: buttonStyle,
          child: buttonChild,
        ),
      ),
    );
  }

  Center retryRequestButton(BuildContext context, MealRecipeState state) {
    return basicButton(
      context,
      Key('refresh_request_button'),
      () => context.read<MealRecipeBloc>().add(
        MealRecipeInit(state.mealId!, state.language!),
      ),
      ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDD9E74),
        minimumSize: const Size.fromHeight(48),
      ),
      Text(AppLocalizations.of(context)!.refreshRequest),
    );
  }

  Center redirectToProfileDetailsButton(BuildContext context) {
    return basicButton(
      context,
      Key('redirect_to_main_page_button'),
      () => context.go('/main-page'),
      ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF2D8B2),
        minimumSize: const Size.fromHeight(48),
      ),
      Text(AppLocalizations.of(context)!.goToMainPage),
    );
  }
}
