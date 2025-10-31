import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/meal_status.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Meal {
  final MealType type;
  final String name;
  final int protein;
  final int carbs;
  final int fat;
  final int calories;
  MealStatus mealStatus;

  Meal({
    required this.type,
    required this.name,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
    required this.mealStatus,
  });

  @override
  String toString() {
    return '${type.nameStr} -> ${mealStatus.nameStr}';
  }
}

class DailySummaryScreen extends StatefulWidget {
  const DailySummaryScreen({super.key});

  @override
  State<DailySummaryScreen> createState() => _DailyNutritionScreenState();
}

class _DailyNutritionScreenState extends State<DailySummaryScreen> {
  int dailyGoal = 1500;
  int eatenCalories = 350;

  MealType selectedMeal = MealType.breakfast;
  final now = DateTime.now();
  final other = DateTime(2025, 10, 31);

  final List<Meal> meals = [
    Meal(
      type: MealType.breakfast,
      name: 'Cornflakes with soy milk',
      protein: 12,
      carbs: 6,
      fat: 5,
      calories: 350,
      mealStatus: MealStatus.eaten,
    ),
    Meal(
      type: MealType.morningSnack,
      name: 'Grilled chicken salad',
      protein: 35,
      carbs: 10,
      fat: 8,
      calories: 420,
      mealStatus: MealStatus.skipped,
    ),
    Meal(
      type: MealType.lunch,
      name: 'Pasta with very, very spicy tomato sauce',
      protein: 18,
      carbs: 60,
      fat: 9,
      calories: 550,
      mealStatus: MealStatus.pending,
    ),
    Meal(
      type: MealType.afternoonSnack,
      name: 'Protein bar',
      protein: 10,
      carbs: 15,
      fat: 5,
      calories: 200,
      mealStatus: MealStatus.skipped,
    ),
    Meal(
      type: MealType.dinner,
      name: 'Protein bar',
      protein: 10,
      carbs: 15,
      fat: 5,
      calories: 200,
      mealStatus: MealStatus.toEat,
    ),
    // Meal(
    //   type: MealType.eveningSnack,
    //   name: 'Protein bar',
    //   protein: 10,
    //   carbs: 15,
    //   fat: 5,
    //   calories: 200,
    // ),
  ];

  void printMealsStatus() {
    print('------------------------');
    for (var meal in meals) {
      print('${meal.type.nameStr} -> ${meal.mealStatus.nameStr}');
    }
  }

  Meal get activeMeal => meals.firstWhere((meal) => meal.type == selectedMeal);

  @override
  Widget build(BuildContext context) {
    final screenWidth = min(MediaQuery.of(context).size.width, 1600.0);
    final isActive =
        (other.isAfter(now) ||
            (now.year == other.year &&
                now.month == other.month &&
                now.day == other.day));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                _buildCaloriesSummary(context, screenWidth),

                const SizedBox(height: 16),

                _buildMealSelector(context, screenWidth),

                const SizedBox(height: 16),

                _buildActiveMealCard(context, screenWidth, isActive),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesSummary(BuildContext context, double screenWidth) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final widgetHeight = min(
          min(40 + screenWidth * 0.25, screenWidth * 0.40),
          360.0,
        );

        final double baseFontSize = widgetHeight * 0.18;
        final double nutritionWidgetSize = min(screenWidth * 0.40, 500);

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
                offset: Offset(0, 8),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: eatenCalories.toDouble()),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  final displayedValue = value.toInt();
                  return ShaderMask(
                    shaderCallback:
                        (bounds) => LinearGradient(
                          colors: [Colors.orangeAccent, Colors.deepOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                    child: Text(
                      '$displayedValue ${AppLocalizations.of(context)?.of_calories} $dailyGoal ${AppLocalizations.of(context)?.kcal}',
                      style: TextStyle(
                        fontSize: baseFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNutritionRings(nutritionWidgetSize, 1.3, [
                    Color(0xFFFFD54F),
                    Color(0xFFFFCA28),
                    Color(0xFFFFB74D),
                  ], Icons.bubble_chart),
                  _buildNutritionRings(nutritionWidgetSize, 0.9, [
                    Color(0xFF92CEFF),
                    Color(0xFF0687F6),
                    Color(0xFF068AF3),
                  ], Icons.opacity),
                  _buildNutritionRings(nutritionWidgetSize, 0.6, [
                    Color(0xFF97FF9A),
                    Color(0xFF66F86D),
                    Color(0xFF3DAF43),
                  ], Icons.fitness_center),
                  _buildNutritionRings(nutritionWidgetSize, 0.3, [
                    Color(0xFFCE93D8),
                    Color(0xFFBA68C8),
                    Color(0xFFAB47BC),
                  ], Icons.local_fire_department),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealSelector(BuildContext context, double widgetWidth) {
    return Container(
      width: widgetWidth,
      padding: EdgeInsets.symmetric(horizontal: max(10, widgetWidth / 30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < meals.length; i++) ...[
            GestureDetector(
              onTap: () => setState(() => selectedMeal = meals[i].type),
              child: Container(
                padding: EdgeInsets.all(widgetWidth / 60),
                decoration: BoxDecoration(
                  color:
                      meals[i].type == selectedMeal
                          ? Colors.orange[200]
                          : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  meals[i].type.toIcon(),
                  color:
                      meals[i].type == selectedMeal
                          ? Colors.deepOrange
                          : Colors.grey,
                  size: min(
                    MealType.values.length * widgetWidth / (12 * meals.length),
                    150,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _macroChip(
    String label,
    num value,
    String unitName,
    Color color, {
    double? width,
  }) {
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

  Widget _buildActiveMealCard(
    BuildContext context,
    double widgetWidth,
    bool isActive,
  ) {
    final meal = activeMeal;
    final bool isEaten = meal.mealStatus ==MealStatus.eaten;
    final bool isSkipped = meal.mealStatus ==MealStatus.skipped;

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
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 5),
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
                AppConfig.mealTypeLabels(context)[meal.type]!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              Builder(
                builder:
                    (ctx) => ElevatedButton.icon(
                      onPressed: () {
                        if (isActive) {
                          setState(() {
                            meal.mealStatus = MealStatus.getNextStatus(
                              meal,
                              meals,
                            );
                          });
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${meal.name} oznaczony jako ${meal.mealStatus.name}!',
                              ),
                            ),
                          );
                        } else {
                          final overlay = Overlay.of(ctx);
                          final renderBox = ctx.findRenderObject() as RenderBox;
                          final position = renderBox.localToGlobal(Offset.zero);

                          OverlayEntry entry = OverlayEntry(
                            builder:
                                (_) => Positioned(
                                  left:
                                      position.dx - renderBox.size.width * 0.2,
                                  top: position.dy - 60,
                                  width: renderBox.size.width * 1.4,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                        4,
                                        8,
                                        4,
                                        8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.cannotEditPastMeals,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                          );

                          overlay.insert(entry);
                          Future.delayed(
                            const Duration(milliseconds: 800),
                            () => entry.remove(),
                          );
                        }
                      },
                      icon: isEaten ? const Icon(Icons.check_circle_outline) : null,
                      label: Text(AppConfig.mealStatusLabels(context)[meal.mealStatus]!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isActive ? Colors.amber.shade600 : Colors.grey,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (!isSkipped && isActive)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Container()),
                    );
                  },
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 320) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _macroChip(AppLocalizations.of(context)!.f_fat, meal.fat,AppLocalizations.of(context)!.g_grams , Color(0xFFFFCA28)),
                        const SizedBox(width: 8),
                        _macroChip(AppLocalizations.of(context)!.p_protein, meal.protein, AppLocalizations.of(context)!.g_grams, Color(0xFF0687F6)),
                        const SizedBox(width: 8),
                        _macroChip(AppLocalizations.of(context)!.c_carbs, meal.carbs, AppLocalizations.of(context)!.g_grams, Color(0xFF3DAF43)),
                      ],
                    ),
                    Row(
                      children: [
                        _macroChip(AppLocalizations.of(context)!.cal_calories, meal.calories, AppLocalizations.of(context)!.kcal, Color(0xFFBA68C8)),
                      ],
                    ),
                  ],
                );
              } else {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _macroChip(AppLocalizations.of(context)!.f_fat, meal.fat,AppLocalizations.of(context)!.g_grams , Color(0xFFFFCA28)),
                    _macroChip(AppLocalizations.of(context)!.p_protein, meal.protein, AppLocalizations.of(context)!.g_grams, Color(0xFF0687F6)),
                    _macroChip(AppLocalizations.of(context)!.c_carbs, meal.carbs, AppLocalizations.of(context)!.g_grams, Color(0xFF3DAF43)),
              _macroChip(AppLocalizations.of(context)!.cal_calories, meal.calories, AppLocalizations.of(context)!.kcal, Color(0xFFBA68C8), width: double.infinity),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRings(
    double ringSize,
    double percent,
    defaultColors,
    IconData icon,
  ) {
    var exceededThresholdColors = [Color(0xFFF84300), Color(0xFFD50000)];
    var backgroundColor1 = Colors.grey.shade300;
    var backgroundColor2 = defaultColors[0];

    int integer = percent.floor();
    double fraction = percent - integer;

    return Center(
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
                  colors: integer < 1 ? defaultColors : exceededThresholdColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: ringSize * 0.15, color: defaultColors[2]),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
