import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/diet_generation/meal_recipe_bloc.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/diet_generation/meal_recipe_events.dart';
import 'package:frontend/foodini.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/ingredient.dart';
import 'package:frontend/models/diet_generation/ingredients.dart';
import 'package:frontend/models/diet_generation/step.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/repository/diet_generation/meals_repository.dart';
import 'package:frontend/states/diet_generation/meal_recipe_states.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:frontend/views/widgets/diet_generation/action_buttons.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid_value.dart';

class MealRecipeScreen extends StatelessWidget {
  final UuidValue mealId;

  const MealRecipeScreen({super.key, required this.mealId});

  @override
  Widget build(BuildContext context) {
    final languageState = context.watch<LanguageCubit>().state;
    final language = Language.fromJson(languageState.languageCode);

    return BlocProvider(
      key: ValueKey('bloc_${mealId.uuid}_${language.code}'),
      create: (context) => MealRecipeBloc(
        context.read<MealsRepository>(),
      )..add(MealRecipeInit(mealId, language)),
      child: Scaffold(
        bottomNavigationBar: BottomNavBar(
          currentRoute: GoRouterState.of(context).uri.path,
          mode: NavBarMode.normal,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _MealRecipe(key: ValueKey('body_${mealId.uuid}_${language.code}')),
          ),
        ),
      ),
    );
  }
}

class _MealRecipe extends StatelessWidget {
  const _MealRecipe({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<MealRecipeBloc, MealRecipeState>(
      builder: (context, state) {
        if (state.processingStatus!.isOngoing) {
          return SizedBox(
            height: screenHeight * 0.5,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (state.processingStatus!.isSuccess) ...[
                _generateMealRecipe(state, context),
              ],

              if (state.processingStatus!.isFailure) ...[
                const Icon(Icons.warning_amber, color: Colors.red, size: 200.0),
                if (state.errorCode == 404) ...[
                  _redirectToProfileDetailsButton(context),
                ] else
                  _retryRequestButton(context, state),
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

  Padding _generateMealRecipe(MealRecipeState state, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal name
          _generateMealNameHeader(state),
          const SizedBox(height: 6),

          // Meal icon
          _generateMealIcon(state, context),
          const SizedBox(height: 6),

          // Meal description
          _generateDescriptionHeader(context),
          const SizedBox(height: 6),
          _generateMealDescription(state),
          const SizedBox(height: 16),

          // Groceries
          _generateGroceriesHeader(context),
          const SizedBox(height: 6),
          for (var ingredient in state.mealRecipe!.ingredients.ingredients)
            _generateIngredientLine(ingredient),
          if (state.mealRecipe!.ingredients.foodAdditives != null)
            _generateFoodAdditives(state.mealRecipe!.ingredients, context),
          const SizedBox(height: 16),

          // Recipe steps
          _generateRecipeHeader(context),
          const SizedBox(height: 6),
          for (int i = 0; i < state.mealRecipe!.steps.length; i++)
            _buildStepCard(state.mealRecipe!.steps[i], i, context),
        ],
      ),
    );
  }

  Text _generateMealNameHeader(MealRecipeState state) {
    return Text(
      state.mealRecipe!.mealName,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Text _generateRecipeHeader(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.recipe,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.deepOrangeAccent,
      ),
    );
  }

  Text _generateGroceriesHeader(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.groceries,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.deepOrangeAccent,
      ),
    );
  }

  Padding _generateIngredientLine(Ingredient ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        _getIngredientText(ingredient),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Padding _generateFoodAdditives(Ingredients ingredients, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        '${AppLocalizations.of(context)!.optional}: ${ingredients.foodAdditives!}',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Text _generateDescriptionHeader(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.mealDescriptions,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Container _generateMealDescription(MealRecipeState state) {
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

  Container _generateMealIcon(MealRecipeState state, BuildContext context) {
    return Container(
      width: 420,
      height: 420,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),

      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: '${Endpoints.mealIcon}/${state.iconUrl!}',
        memCacheWidth: 420,
        memCacheHeight: 420,
        fit: BoxFit.cover,
        placeholder:
            (context, url) =>
                SizedBox(child: Center(child: CircularProgressIndicator())),
        errorWidget: (context, url, error) {
          CachedNetworkImage.evictFromCache(
            '${Endpoints.mealIcon}/${state.iconUrl!}',
          );

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber, color: Colors.red, size: 200.0),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.errorWhileFetchingMealIcon,
                style: Styles.errorStyle,
              ),
              _retryRequestButton(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepCard(MealRecipeStep step, int idx, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${idx + 1}. ',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (step.optional == true)
              TextSpan(
                text: '(${AppLocalizations.of(context)!.optional}) ',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
            TextSpan(
              text: step.description,
              style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87,),
            ),
          ],
        ),
      ),
    );
  }

  String _getIngredientText(Ingredient ingredient) {
    if (ingredient.optionalNote != null) {
      return '• ${ingredient.volume} ${ingredient.unit} ${ingredient
          .name} (${ingredient.optionalNote})';
    }
    return '• ${ingredient.volume} ${ingredient.unit} ${ingredient.name}';
  }

  Center _retryRequestButton(BuildContext context, MealRecipeState state) {
    return customRetryButton(
      Key('refresh_request_button'),
      () => context.read<MealRecipeBloc>().add(
        MealRecipeInit(state.mealId!, state.language!),
      ),
      Text(AppLocalizations.of(context)!.refreshRequest),
    );
  }

  Center _redirectToProfileDetailsButton(BuildContext context) {
    return customRedirectButton(
      Key('redirect_to_main_page_button'),
      () => context.go('/main-page'),
      Text(AppLocalizations.of(context)!.goToMainPage),
    );
  }
}
