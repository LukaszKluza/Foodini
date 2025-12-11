import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/diet_generation/daily_summary_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/styles.dart';
import 'package:frontend/events/diet_generation/daily_summary_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/macros_summary.dart';
import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/states/diet_generation/daily_summary_states.dart';
import 'package:frontend/utils/diet_generation/date_tools.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:frontend/views/widgets/diet_generation/action_button.dart';
import 'package:frontend/views/widgets/diet_generation/bottom_sheet.dart';
import 'package:frontend/views/widgets/diet_generation/delete_meal_pop_up.dart';
import 'package:frontend/views/widgets/diet_generation/edit_meal_pop_up.dart';
import 'package:frontend/views/widgets/diet_generation/error_box.dart';
import 'package:frontend/views/widgets/diet_generation/macros_items.dart';
import 'package:frontend/views/widgets/diet_generation/new_meal_pop_up.dart';
import 'package:go_router/go_router.dart';

class MealDetailsScreen extends StatefulWidget {
  final MealType mealType;
  final DateTime selectedDate;

  const MealDetailsScreen({
    super.key,
    required this.mealType,
    required this.selectedDate,
  });

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DailySummaryBloc>().add(GetDailySummary(widget.selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DailySummaryBloc, DailySummaryState>(
        builder: (context, state) {
          final List<MealInfo> mealItems = state.getMealsByMealType(widget.mealType);
          final calculatedMacrosSummary = mealItems.isNotEmpty &&
              dateComparator(state.dailySummary!.day, widget.selectedDate) == 0 ? MacrosSummary.calculateTotalMacros(mealItems) : MacrosSummary.zero();

          return Scaffold(
            body: _MealDetails(mealType: widget.mealType, state: state, widgetSelectedDate: widget.selectedDate),
            bottomNavigationBar: BottomNavBar(
              currentRoute: GoRouterState.of(context).uri.path,
              mode: NavBarMode.wizard,
              prevRoute: '/daily-summary/${widget.selectedDate}',
            ),
            bottomSheet: CustomBottomSheet(
              mealTypeMacrosSummary: calculatedMacrosSummary,
              mealType: widget.mealType,
            ),
          );
         },
      ),
    );
  }
}

class _MealDetails extends StatelessWidget {
  final MealType mealType;
  final DailySummaryState state;
  final DateTime widgetSelectedDate;

  const _MealDetails({required this.mealType, required this.state, required this.widgetSelectedDate});

  @override
  Widget build(BuildContext context) {
    final List<MealInfo> mealItems = state.getMealsByMealType(mealType);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 140),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
             if ((mealItems.isNotEmpty && dateComparator(state.dailySummary!.day, widgetSelectedDate) != 0) || mealItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    generateMealNameHeader(context, mealType),
                    const SizedBox(height: 16),
                    buildErrorBox(
                      context,
                      AppLocalizations.of(context)!.noMealData,
                      button: ActionButton(
                        onPressed: showNewMealPopUp(context, widgetSelectedDate, mealType),
                        color: Colors.orangeAccent,
                        label: AppLocalizations.of(context)!.addNewMeal,
                      ),
                    ),
                  ],
                ),
              ) else
                generateMealDetails(context, mealType, mealItems),
              if (state.updatingMealDetails. isFailure)
                Text(
                  state.getMessage!(context),
                  style: Styles.errorStyle,
                  textAlign: TextAlign.center,
                ),
              if ((state.dietGeneratingInfo.processingStatus.isOngoing && dateComparator(state.dietGeneratingInfo.day!, widgetSelectedDate) == 0) || state.gettingDailySummaryStatus.isOngoing || state.updatingMealDetails. isOngoing)
                const Center(child: CircularProgressIndicator()),
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
          generateMealNameHeader(context, mealType),
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
                    onPressed: showNewMealPopUp(context, widgetSelectedDate, mealType),
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
          generateMealItemNameHeader(mealInfo.name),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildCarbsItem(context, mealInfo.plannedCarbs),
              buildFatItem(context, mealInfo.plannedFat),
              buildProteinItem(context, mealInfo.plannedProtein),
              buildCaloriesItem(context, mealInfo.plannedCalories),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              ActionButton(
                onPressed: showEditMealPopUp(context, widgetSelectedDate, mealType, mealInfo.mealId, mealInfo),
                color: Colors.orange[300]!,
                label: AppLocalizations.of(context)!.edit,
              ),
              const SizedBox(width: 12),
              ActionButton(
                onPressed: showDeleteMealPopUp(
                context,
                widgetSelectedDate,
                mealType,
                mealInfo.mealId,
                mealName: mealInfo.name,
              ),
                color: Colors.redAccent,
                label: AppLocalizations.of(context)!.delete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Text generateMealNameHeader(BuildContext context, MealType mealType) {
    return Text(
      AppConfig.mealTypeLabels(context)[mealType]!,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  Widget generateMealItemNameHeader(String label) {
    return AutoSizeText(
        label,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        minFontSize: 12,
      );
  }
}

BoxShadow getShadowBox() =>
    BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -4));

