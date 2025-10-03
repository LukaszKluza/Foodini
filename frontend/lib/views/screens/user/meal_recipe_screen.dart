import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/blocs/diet_prediction/meal_recipe_bloc.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/diet_prediction/diet_prediction_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_prediction/ingredient.dart';
import 'package:frontend/models/diet_prediction/step.dart';
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
                generateMealRecipe(state, context),
              ],

              if (state.processingStatus!.isFailure) ...[
                const Icon(
                  Icons.warning_amber,
                  color: Colors.red,
                  size: 200.0,
                ),
                if (state.errorCode == 404) ...[
                  Text(
                    AppLocalizations.of(context)!.fillFormToSeePredictions,
                    style: TextStyle(
                      fontSize: 30.sp.clamp(20.0, 40.0),
                      color: Colors.orangeAccent,
                    ),
                  ),
                  redirectToProfileDetailsButton(context),
                ] else
                  retryRequestButton(context),
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
          generateMealIcon(state),
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

  Padding generateRecipeStep(MealRecipeState state, int i, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(getText(state.mealRecipe!.steps[i], i, context),style: const TextStyle(fontSize: 16)),
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

  Padding generateIngredientLine(Ingredient ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        '• ${ingredient.name} (${ingredient.volume} ${ingredient.unit})',
        style: const TextStyle(fontSize: 16),
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

  Container generateMealIcon(MealRecipeState state) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
          ),
        ],
      ),

      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: '${Endpoints.mealIcon}/${state.iconUrl!}',
        fit: BoxFit.cover,
        placeholder: (context, url) => SizedBox(
          height: 100,
          width: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }

  String getText(MealRecipeStep step, int idx, BuildContext context){
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
          onPressed: () {
            // _message = null;
            // _errorCode = null;
            onPressed?.call();
          },
          style: buttonStyle,
          child: buttonChild,
        ),
      ),
    );
  }

  Center retryRequestButton(BuildContext context) {
    return basicButton(
      context,
      Key('refresh_request_button'),
          () => context.read<MacrosChangeBloc>().add(LoadInitialMacros()),
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
      Key('redirect_to_profile_details_button'),
          () => context.go('/profile-details'),
      ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF2D8B2),
        minimumSize: const Size.fromHeight(48),
      ),
      Text(AppLocalizations.of(context)!.redirectToProfileDetails),
    );
  }

}
