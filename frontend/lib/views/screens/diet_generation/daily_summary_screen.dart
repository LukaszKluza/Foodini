import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/diet_generation/daily_summary_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/events/diet_generation/daily_summary_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/meal_info.dart';
import 'package:frontend/models/diet_generation/meal_status.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/states/diet_generation/daily_summary_states.dart';
import 'package:frontend/utils/logger.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:uuid/uuid_value.dart';

class DailySummaryScreen extends StatefulWidget {
  final DateTime selectedDate;

  const DailySummaryScreen({
    super.key,
    required this.selectedDate,
  });

  @override
  State<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends State<DailySummaryScreen> {
  MealType? selectedMealType;

  @override
  void initState() {
    super.initState();
    context.read<DailySummaryBloc>().add(GetDailySummary(widget.selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = min(MediaQuery.of(context).size.width, 1600.0);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: BlocBuilder<DailySummaryBloc, DailySummaryState>(
          builder: (context, state) {
            if (state is DailySummaryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DailySummaryError) {
              return Center(
                child: Text(
                  state.message ?? 'Data loading error',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              );
            } else if (state is DailySummaryLoaded) {
              final summary = state.dailySummary;

              final meals = summary.meals;
              final mealTypes = meals.keys.toList();

              if (mealTypes.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context)?.noMealsForToday ?? 'No meals',
                  ),
                );
              }

              selectedMealType ??= mealTypes.first;
              final activeMeal = selectedMealType!;
              final activeMealInfo = meals[activeMeal]!;
              final dailyGoal = summary.targetCalories;
              final eatenCalories = summary.eatenCalories;

              final isActiveDay = widget.selectedDate.year == summary.day.year &&
                  widget.selectedDate.month == summary.day.month &&
                  widget.selectedDate.day == summary.day.day;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      _buildCaloriesSummary(
                        context,
                        screenWidth,
                        dailyGoal,
                        eatenCalories,
                      ),
                      const SizedBox(height: 16),
                      _buildMealSelector(
                        context,
                        screenWidth,
                        mealTypes,
                      ),
                      const SizedBox(height: 16),
                      _buildActiveMealCard(
                        context,
                        screenWidth,
                        isActiveDay,
                        activeMeal,
                        activeMealInfo,
                        meals,
                        widget.selectedDate,
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCaloriesSummary(
    BuildContext context,
    double screenWidth,
    int dailyGoal,
    int eatenCalories,
  ) {
    return BlocBuilder<DailySummaryBloc, DailySummaryState>(
      builder: (context, state) {
        if (state is! DailySummaryLoaded) return const SizedBox.shrink();
        final summary = state.dailySummary;

        final proteinPercent =
            (summary.eatenProtein / summary.targetProtein).toDouble().clamp(0.0, 1.0);
        final carbsPercent =
            (summary.eatenCarbs / summary.targetCarbs).toDouble().clamp(0.0, 1.0);
        final fatPercent =
            (summary.eatenFat / summary.targetFat).toDouble().clamp(0.0, 1.0);

        final widgetHeight =
            min(min(40 + screenWidth * 0.25, screenWidth * 0.40), 360.0);
        final double baseFontSize = widgetHeight * 0.18;
        final double ringSize = min(screenWidth * 0.25, 300);

        return Container(
          width: screenWidth,
          height: widgetHeight,
          padding: EdgeInsets.symmetric(
            vertical: 15,
            horizontal: max(10, screenWidth / 30),
          ),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            boxShadow: [
              BoxShadow(
                color: Colors.deepOrangeAccent.withAlpha(70),
                offset: const Offset(0, 8),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: eatenCalories.toDouble()),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  final displayedValue = value.toInt();
                  return ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.orangeAccent, Colors.deepOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    child: Text(
                      '$displayedValue / $dailyGoal ${AppLocalizations.of(context)?.kcal}',
                      style: TextStyle(
                        fontSize: baseFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNutritionRings(
                    ringSize,
                    fatPercent,
                    const [Color(0xFFFFD54F), Color(0xFFFFB74D)],
                    Icons.bubble_chart,
                    AppLocalizations.of(context)!.f_fat,
                    summary.eatenFat,
                    summary.targetFat,
                  ),
                  _buildNutritionRings(
                    ringSize,
                    proteinPercent,
                    const [Color(0xFF92CEFF), Color(0xFF0687F6)],
                    Icons.fitness_center,
                    AppLocalizations.of(context)!.p_protein,
                    summary.eatenProtein,
                    summary.targetProtein,
                  ),
                  _buildNutritionRings(
                    ringSize,
                    carbsPercent,
                    const [Color(0xFF97FF9A), Color(0xFF3DAF43)],
                    Icons.opacity,
                    AppLocalizations.of(context)!.c_carbs,
                    summary.eatenCarbs,
                    summary.targetCarbs,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealSelector(
    BuildContext context,
    double widgetWidth,
    List<MealType> meals,
  ) {
    return Container(
      width: widgetWidth,
      padding: EdgeInsets.symmetric(horizontal: max(10, widgetWidth / 30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var meal in meals)
            GestureDetector(
              onTap: () => setState(() => selectedMealType = meal),
              child: Container(
                padding: EdgeInsets.all(widgetWidth / 60),
                decoration: BoxDecoration(
                  color: meal == selectedMealType
                      ? Colors.orange[200]
                      : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  meal.toIcon(),
                  color: meal == selectedMealType
                      ? Colors.deepOrange
                      : Colors.grey,
                  size: min(MealType.values.length * widgetWidth /
                      (12 * meals.length), 150),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveMealCard(
    BuildContext context,
    double widgetWidth,
    bool isActive,
    MealType activeMealType,
    MealInfo activeMealInfo,
    Map<MealType, MealInfo> allMeals,
    DateTime selectedDay,
  ) {
    final bool isEaten = activeMealInfo.status == MealStatus.eaten;
    final bool isSkipped = activeMealInfo.status == MealStatus.skipped;


    return Container(
      width: widgetWidth,
      padding: EdgeInsets.symmetric(
        vertical: 15,
        horizontal: max(10, widgetWidth / 30),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade300, Colors.deepOrange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppConfig.mealTypeLabels(context)[activeMealType]!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (!isActive) {
                    // Show a small tooltip if trying to edit past days
                    final overlay = Overlay.of(context);
                    final renderBox = context.findRenderObject() as RenderBox;
                    final position = renderBox.localToGlobal(Offset.zero);

                    OverlayEntry entry = OverlayEntry(
                      builder: (_) => Positioned(
                        left: position.dx - renderBox.size.width * 0.2,
                        top: position.dy - 60,
                        width: renderBox.size.width * 1.4,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.cannotEditPastMeals,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    );

                    overlay.insert(entry);
                    Future.delayed(const Duration(milliseconds: 800), () => entry.remove());
                    return;
                  }

                  final nextStatus = MealStatus.getNextStatus(activeMealType, allMeals);
                  logger.w(nextStatus);
                  context.read<DailySummaryBloc>().add(
                        ChangeMealStatus(
                          day: selectedDay,
                          mealId: activeMealInfo.mealId as UuidValue,
                          status: nextStatus,
                        ),
                      );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${activeMealInfo.name ?? AppConfig.mealTypeLabels(context)[activeMealType]} '
                        '${AppLocalizations.of(context)!.markedAs} '
                        '${AppConfig.mealStatusLabels(context)[nextStatus]}!',
                      ),
                    ),
                  );
                },
                icon: isEaten
                    ? const Icon(Icons.check_circle_outline)
                    : isSkipped
                        ? const Icon(Icons.remove_circle_outline)
                        : const Icon(Icons.fastfood),
                label: Text(
                  AppConfig.mealStatusLabels(context)[activeMealInfo.status]!,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? Colors.amber.shade600 : Colors.grey,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            activeMealInfo.name ?? 'Custom Meal',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _macroChip(
                  AppLocalizations.of(context)!.f_fat,
                  activeMealInfo.fat ?? 0,
                  AppLocalizations.of(context)!.g_grams,
                  const Color(0xFFFFCA28)),
              _macroChip(
                  AppLocalizations.of(context)!.p_protein,
                  activeMealInfo.protein ?? 0,
                  AppLocalizations.of(context)!.g_grams,
                  const Color(0xFF0687F6)),
              _macroChip(
                  AppLocalizations.of(context)!.c_carbs,
                  activeMealInfo.carbs ?? 0,
                  AppLocalizations.of(context)!.g_grams,
                  const Color(0xFF3DAF43)),
              _macroChip(
                  AppLocalizations.of(context)!.cal_calories,
                  activeMealInfo.calories ?? 0,
                  AppLocalizations.of(context)!.kcal,
                  const Color(0xFFBA68C8),
                  width: double.infinity),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroChip(
      String label, num value, String unitName, Color color,
      {double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value $unitName',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNutritionRings(
    double ringSize,
    double percent,
    List<Color> colors,
    IconData icon,
    String label,
    double eaten,
    double target,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: percent),
          duration: const Duration(seconds: 1),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, _) {
            return CircularPercentIndicator(
              radius: ringSize * 0.18,
              lineWidth: ringSize * 0.07,
              animation: false,
              percent: animatedValue,
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: Colors.grey.shade300,
              linearGradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              center: Text(
                  label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
                  )
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Text(
          '${eaten.toStringAsFixed(1)} / ${target.toStringAsFixed(1)} g',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
