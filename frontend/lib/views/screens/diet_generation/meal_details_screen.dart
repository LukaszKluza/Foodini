import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/diet_generation/daily_summary_bloc.dart';
import 'package:frontend/events/diet_generation/daily_summary_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/models/diet_generation/meal_item.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/states/diet_generation/daily_summary_states.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:frontend/views/widgets/diet_generation/action_button.dart';
import 'package:frontend/views/widgets/diet_generation/bottom_sheet.dart';
import 'package:frontend/views/widgets/diet_generation/macros_items.dart';
import 'package:frontend/views/widgets/diet_generation/pop_up.dart';
import 'package:go_router/go_router.dart';

class MealDetailsScreen extends StatelessWidget {
  final MealType mealType;

  const MealDetailsScreen({super.key, required this.mealType});

  @override
  Widget build(BuildContext context) {
    final dateTime = DateTime(2025, 11, 3);
    context.read<DailySummaryBloc>().add(GetDailySummary(dateTime));

    return Scaffold(
      body: BlocBuilder<DailySummaryBloc, DailySummaryState>(
        builder: (context, state) {
          if (state is DailySummaryLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is DailySummaryError) {
            return Center(
              child: Text(state.message ?? 'Błąd ładowania danych'),
            );
          }

          if (state is DailySummaryLoaded) {
            final meal = state.dailySummary.meals[mealType];
            if (meal == null) {
              return const Center(child: Text('Brak danych dla tego posiłku'));
            }

            final mealItems = [meal];

            return Scaffold(
              body: _MealDetails(mealType: mealType, mealItems: mealItems),
              bottomNavigationBar: BottomNavBar(
                currentRoute: GoRouterState.of(context).uri.path,
                mode: NavBarMode.wizard,
                prevRoute: '/diet-preferences',
              ),
              bottomSheet: CustomBottomSheet(mealTypeMacrosSummary: calculateTotalMacros(mealItems)),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MealDetails extends StatelessWidget {
  final MealType mealType;
  final List<MealInfo> mealItems;

  const _MealDetails({required this.mealType, required this.mealItems});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 140),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              generateMealDetails(context, mealType, mealItems),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Padding generateMealDetails(BuildContext context, MealType mealType, List<MealInfo> mealItems) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          generateMealNameHeader(mealType),
          ...mealItems.map((mealItem) {
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

  Container createMealItemWidget(BuildContext context, MealInfo mealInfo) {
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
          generateMealItemNameHeader(mealInfo.name!),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildCarbsItem(context, mealInfo.carbs!),
              buildFatItem(context, mealInfo.fat!),
              buildProteinItem(context, mealInfo.protein!),
              buildCaloriesItem(context, mealInfo.calories!),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              ActionButton(
                onPressed: showPopUp(context, mealInfo: mealInfo),
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

  Text generateMealNameHeader(MealType mealType) {
    return Text(
      mealType.displayName,
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


BoxShadow getShadowBox() =>
    BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4));

MealTypeMacrosSummary calculateTotalMacros(List<MealInfo> meals) {
  double totalProtein = 0;
  double totalCarbs = 0;
  double totalFat = 0;
  int totalCalories = 0;

  for (final meal in meals) {
    totalProtein += meal.protein!;
    totalCarbs += meal.carbs!;
    totalFat += meal.fat!;
    totalCalories += meal.calories!;
  }

  return MealTypeMacrosSummary(
    carbs: double.parse(totalCarbs.toStringAsFixed(2)),
    fat: double.parse(totalFat.toStringAsFixed(2)),
    protein: double.parse(totalProtein.toStringAsFixed(2)),
    calories: totalCalories,
  );
}

