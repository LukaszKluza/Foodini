import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/diet_generation/daily_summary_bloc.dart';
import 'package:frontend/events/diet_generation/daily_summary_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/meal_item.dart';
import 'package:frontend/states/diet_generation/daily_summary_states.dart';
import 'package:frontend/states/diet_generation/meal_recipe_states.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:frontend/views/widgets/diet_generation/action_button.dart';
import 'package:frontend/views/widgets/diet_generation/bottom_sheet.dart';
import 'package:frontend/views/widgets/diet_generation/pop_up.dart';
import 'package:go_router/go_router.dart';

class MealDetailsScreen extends StatelessWidget {
  const MealDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime(2025, 11, 3);
    context.read<DailySummaryBloc>().add(GetDailySummary(dateTime));

    return Scaffold(
      body: _MealDetails(),
      bottomNavigationBar: BottomNavBar(
        currentRoute: GoRouterState.of(context).uri.path,
        mode: NavBarMode.wizard,
        prevRoute: '/diet-preferences',
      ),
      bottomSheet: CustomBottomSheet(),
    );
  }
}

class _MealDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailySummaryBloc, DailySummaryState>(
      builder: (context, state) {
        if (state is DailySummaryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DailySummaryError) {
          return Center(
            child: Text(
              state.message ?? 'Błąd ładowania danych',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is DailySummaryLoaded) {
          print('Nowy stan: ${state.dailySummary.toJson()}');

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 140),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    generateMealDetails(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Padding generateMealDetails(BuildContext context) {
    final blocState = context.read<DailySummaryBloc>().state;

    print(blocState.runtimeType);

    if(blocState is DailySummaryLoaded){
      print(blocState.dailySummary.toJson());
    }

    List<MealItem> meals = [
      MealItem(name: 'Cola', carbs: 0, fat: 0, protein: 0, calories: 3),
      MealItem(name: 'Cola', carbs: 0, fat: 0, protein: 0, calories: 3),
      MealItem(name: 'Cola', carbs: 0, fat: 0, protein: 0, calories: 3),
      MealItem(name: 'Cola', carbs: 0, fat: 0, protein: 0, calories: 3),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          generateMealNameHeader(),
          ...meals.map((mealItem) {
            return Column(children: [createMealItemWidget(context, mealItem)]);
          }),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  ActionButton(
                    onPressed: showPopUp(context),
                    color: Colors.orangeAccent,
                    label: AppLocalizations.of(context)!.addNewMeal,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container createMealItemWidget(BuildContext context, MealItem mealItem) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [getShadowBox()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          generateMealItemNameHeader(mealItem.name),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildCarbsItem(context, mealItem.carbs),
              buildFatItem(context, mealItem.fat),
              buildProteinItem(context, mealItem.protein),
              buildCaloriesItem(context, mealItem.calories),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              ActionButton(
                onPressed: showPopUp(context, mealItem: mealItem),
                color: Colors.orange[300]!,
                label: AppLocalizations.of(context)!.edit,
              ),
              const SizedBox(width: 12),
              ActionButton(
                onPressed: () {},
                color: Colors.redAccent,
                label: AppLocalizations.of(context)!.delete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Text generateMealNameHeader({MealRecipeState? state}) {
    return Text(
      'Lunch',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Text generateMealItemNameHeader(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }
}

Column buildMacroItem(
  BuildContext context,
  Icon icon,
  String value,
  String key,
) {
  return Column(
    children: [
      icon,
      SizedBox(height: 4),
      Text(key, style: TextStyle(color: Colors.grey, fontSize: 12)),
      Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}

Column buildCarbsItem(BuildContext context, int value) {
  return buildMacroItem(
    context,
    Icon(Icons.local_fire_department, color: Colors.orange),
    '${value}g',
    AppLocalizations.of(context)!.carbsG,
  );
}

Column buildFatItem(BuildContext context, int value) {
  return buildMacroItem(
    context,
    Icon(Icons.bubble_chart, color: Colors.yellow[700]!),
    '${value}g',
    AppLocalizations.of(context)!.fatG,
  );
}

Column buildProteinItem(BuildContext context, int value) {
  return buildMacroItem(
    context,
    Icon(Icons.fitness_center, color: Colors.green),
    '${value}g',
    AppLocalizations.of(context)!.proteinG,
  );
}

Column buildCaloriesItem(BuildContext context, int value) {
  return buildMacroItem(
    context,
    Icon(Icons.local_fire_department, color: Colors.redAccent),
    '${value}kcal',
    AppLocalizations.of(context)!.calories,
  );
}

BoxShadow getShadowBox() =>
    BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4));
