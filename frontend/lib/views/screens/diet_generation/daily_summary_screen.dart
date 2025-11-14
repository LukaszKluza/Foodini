import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
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
import 'package:frontend/utils/diet_generation/date_comparator.dart';
import 'package:frontend/views/widgets/bottom_nav_bar_date.dart';
import 'package:frontend/views/widgets/generate_meals_button.dart';
import 'package:frontend/views/widgets/title_text.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:uuid/uuid_value.dart';

class DailySummaryScreen extends StatefulWidget {
  final DateTime selectedDate;

  DailySummaryScreen({Key? key, required this.selectedDate})
      : super(key: ValueKey('daily_summary_$selectedDate'));

  @override
  State<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends State<DailySummaryScreen> {
  SnackBar? currentSnackBar;
  MealType? selectedMealType;

  String formatForUrl(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    context.read<DailySummaryBloc>().add(GetDailySummary(widget.selectedDate));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentSnackBar = SnackBar(
        content: Text(AppLocalizations.of(context)!.dietOutdated),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.orangeAccent[700],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final screenWidth = min(MediaQuery.of(context).size.width, 1600.0);

    final prevDate = widget.selectedDate.subtract(const Duration(days: 1));
    final nextDate = widget.selectedDate.add(const Duration(days: 1));
    final prevRoute = '/daily-summary/${formatForUrl(prevDate)}';
    final nextRoute = '/daily-summary/${formatForUrl(nextDate)}';

    final now = DateTime.now();

    final isActiveDay = (
        widget.selectedDate.isAfter(now) ||
            (
                now.year == widget.selectedDate.year &&
                now.month == widget.selectedDate.month &&
                now.day == widget.selectedDate.day
            )
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: TitleTextWidgets.scaledTitle(AppLocalizations.of(context)!.dailySummary),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<DailySummaryBloc, DailySummaryState>(
          builder: (context, state) {
            if (state.dietGeneratingInfo.processingStatus.isOngoing
                && dateComparator(state.dietGeneratingInfo.day!, widget.selectedDate) == 0) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.dietGeneratingInfo.processingStatus.isFailure
                && dateComparator(state.dietGeneratingInfo.day!, widget.selectedDate) == 0
            ) {
              return Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 100.0),
                      child: Text(
                        state.getMessage!(context),
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    ),
                  ),
                  if (isActiveDay)
                    DietGenerationInfoButton(
                      selectedDay: widget.selectedDate,
                      isRegenerateMode: false,
                      onPressed: () {
                        context.read<DailySummaryBloc>().add(GenerateMealPlan(day: widget.selectedDate));
                      },
                    ),
                ],
              );
            } else if (state.dailySummary != null && dateComparator(state.dailySummary!.day, widget.selectedDate) == 0) {
              final summary = state.dailySummary!;

              final meals = summary.meals;
              final mealTypes = meals.keys.toList()..sort((a, b) => a.value.compareTo(b.value));

              if (mealTypes.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context)!.noMealsForToday,
                  ),
                );
              }

              if (state.dailySummary!.isOutDated) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    messenger.showSnackBar(currentSnackBar!);
                  });
              } else {
                messenger.hideCurrentSnackBar();
              }

              selectedMealType ??= meals.entries.firstWhere(
                    (mealInfo) => mealInfo.value.status == MealStatus.pending,
                orElse: () => meals.entries.last,
              ).key;
              final activeMeal = selectedMealType!;
              final activeMealInfo = meals[activeMeal]!;
              final dailyGoal = summary.targetCalories;
              final eatenCalories = summary.eatenCalories;

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
      bottomNavigationBar: BottomNavBarDate(
        prevRoute: prevRoute,
        nextRoute: nextRoute,
        selectedDate: widget.selectedDate,
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
        final summary = state.dailySummary!;

        final proteinPercent =
            (summary.eatenProtein / summary.targetProtein).toDouble();
        final carbsPercent =
            (summary.eatenCarbs / summary.targetCarbs).toDouble();
        final fatPercent =
            (summary.eatenFat / summary.targetFat).toDouble();

        final widgetHeight =
            min(min(40 + screenWidth * 0.25, screenWidth * 0.40), 360.0);
        final double baseFontSize = widgetHeight * 0.18;
        final double ringSize = min(screenWidth * 0.40, 500);

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
                    carbsPercent,
                    const [Color(0xFF97FF9A), Color(0xFF66F86D), Color(0xFF3DAF43)],
                    Icons.local_fire_department,
                    AppLocalizations.of(context)!.c_carbs,
                    baseFontSize,
                    summary.eatenCarbs,
                    summary.targetCarbs,
                  ),
                  _buildNutritionRings(
                    ringSize,
                    fatPercent,
                    const [Color(0xFFFFD54F), Color(0xFFFFCA28), Color(0xFFFFB74D)],
                    Icons.bubble_chart,
                    AppLocalizations.of(context)!.f_fat,
                    baseFontSize,
                    summary.eatenFat,
                    summary.targetFat,
                  ),
                  _buildNutritionRings(
                    ringSize,
                    proteinPercent,
                    const [Color(0xFF92CEFF), Color(0xFF0687F6), Color(0xFF068AF3)],
                    Icons.fitness_center,
                    AppLocalizations.of(context)!.p_protein,
                    baseFontSize,
                    summary.eatenProtein,
                    summary.targetProtein,
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          final mealId = activeMealInfo.mealId;
          if (mealId != null) {
            context.push('/meal-recipe/$mealId');
          }
        },
        child: Container(
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
                  Builder(
                      builder: (ctx) => ElevatedButton.icon(
                      onPressed: () {
                        if (!isActive) {
                          final overlay = Overlay.of(ctx);
                          final renderBox = ctx.findRenderObject() as RenderBox;
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
                        } else {
                          final nextStatus = MealStatus.getNextStatus(activeMealType, allMeals);
                          context.read<DailySummaryBloc>().add(
                            ChangeMealStatus(
                              day: selectedDay,
                              mealId: activeMealInfo.mealId as UuidValue,
                              status: nextStatus,
                            ),
                          );
                        }
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
                  )
                ],
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AutoSizeText(
                      activeMealInfo.name!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      minFontSize: 12,
                    ),
                  ),
                  if (!isSkipped && isActive)
                    GestureDetector(
                      onTap: () => context.push('/meal-details/${activeMealType.nameStr}/$selectedDay'),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.black54,
                        size: 25,
                      ),
                    ),
                ],
            ),

              const SizedBox(height: 12),

              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 380) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _carbsChip(activeMealInfo),
                            const SizedBox(width: 8),
                            _fatChip(activeMealInfo),
                            const SizedBox(width: 8),
                            _proteinChip(activeMealInfo),
                          ],
                        ),
                        Row(children: [_caloriesChip(activeMealInfo)]),
                      ],
                    );
                  } else {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _carbsChip(activeMealInfo),
                        _fatChip(activeMealInfo),
                        _proteinChip(activeMealInfo),
                        _caloriesChip(activeMealInfo, width: double.infinity)
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
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

  Widget _fatChip(MealInfo activeMealInfo){
    return _macroChip(AppLocalizations.of(context)!.f_fat, activeMealInfo.fat ?? 0 ,AppLocalizations.of(context)!.g_grams , Color(0xFFFFCA28));
  }

  Widget _proteinChip(MealInfo activeMealInfo){
    return _macroChip(AppLocalizations.of(context)!.p_protein, activeMealInfo.protein ?? 0, AppLocalizations.of(context)!.g_grams, Color(0xFF0687F6));
  }

  Widget _carbsChip(MealInfo activeMealInfo){
    return _macroChip(AppLocalizations.of(context)!.c_carbs, activeMealInfo.carbs ?? 0, AppLocalizations.of(context)!.g_grams, Color(0xFF3DAF43));
  }

  Widget _caloriesChip(MealInfo activeMealInfo, {double? width}){
    return _macroChip(AppLocalizations.of(context)!.cal_calories, activeMealInfo.calories ?? 0, AppLocalizations.of(context)!.kcal, Color(0xFFBA68C8), width: width);
  }

  Widget _buildNutritionRings(
    double ringSize,
    double percent,
    List<Color> colors,
    IconData icon,
    String label,
    double baseFontSize,
    double eaten,
    double target,
  ) {
    var exceededThresholdColors = [Color(0xFFF84300), Color(0xFFD50000)];

    final tooltipMessage = '${eaten.toStringAsFixed(1)} / ${target.toStringAsFixed(1)} g';

    var backgroundColor1 = Colors.grey.shade300;
    var backgroundColor2 = colors[0];
    int integer = percent.floor();
    double fraction = percent - integer;

    return Center(
      child: Tooltip(
        message: tooltipMessage,
        preferBelow: true,
        triggerMode: TooltipTriggerMode.tap,
        textStyle: TextStyle(
          fontSize: baseFontSize * 0.45,
          color: Colors.white,
        ),

        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: fraction),
          duration: const Duration(seconds: 2),
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularPercentIndicator(
                  radius: ringSize * 0.20,
                  lineWidth: ringSize * 0.08,
                  animation: false,
                  percent: animatedValue,
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor:
                      integer < 1 ? backgroundColor1 : backgroundColor2,
                  linearGradient: LinearGradient(
                    colors: integer < 1 ? colors : exceededThresholdColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: ringSize * 0.15, color: colors.last,),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
