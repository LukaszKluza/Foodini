import 'dart:math';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

enum MealType { breakfast, lunch, dinner, snack }

class Meal {
  final MealType type;
  final String name;
  final int protein;
  final int carbs;
  final int fat;
  final int calories;

  Meal({
    required this.type,
    required this.name,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
  });
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

  final List<Meal> meals = [
    Meal(
      type: MealType.breakfast,
      name: 'Cornflakes with soy milk',
      protein: 12,
      carbs: 6,
      fat: 5,
      calories: 350,
    ),
    Meal(
      type: MealType.lunch,
      name: 'Grilled chicken salad',
      protein: 35,
      carbs: 10,
      fat: 8,
      calories: 420,
    ),
    Meal(
      type: MealType.dinner,
      name: 'Pasta with tomato sauce',
      protein: 18,
      carbs: 60,
      fat: 9,
      calories: 550,
    ),
    Meal(
      type: MealType.snack,
      name: 'Protein bar',
      protein: 10,
      carbs: 15,
      fat: 5,
      calories: 200,
    ),
  ];

  Meal get activeMeal => meals.firstWhere((meal) => meal.type == selectedMeal);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildCaloriesSummary(context),

              const SizedBox(height: 16),

              _buildMealSelector(),

              const SizedBox(height: 16),

              _buildActiveMealCard(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesSummary(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final screenWidth = min(MediaQuery.of(context).size.width, 1600.0);
        final widgetHeight = min(40 + screenWidth * 0.25, screenWidth * 0.40);

        final double baseFontSize = widgetHeight * 0.18;
        final double nutritionWidgetSize = screenWidth * 0.40;

        return Container(
          width: screenWidth,
          height: widgetHeight,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
                      '$displayedValue of $dailyGoal kcal',
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNutritionRings(nutritionWidgetSize, 1.3, [
                    Color(0xFFFFD54F),
                    Color(0xFFFFCA28),
                    Color(0xFFFFB74D),
                  ],Icons.bubble_chart),
                  SizedBox(width: screenWidth * 0.05),
                  _buildNutritionRings(nutritionWidgetSize, 0.9, [
                    Color(0xFF92CEFF),
                    Color(0xFF0687F6),
                    Color(0xFF068AF3),
                  ], Icons.opacity),
                  SizedBox(width: screenWidth * 0.05),
                  _buildNutritionRings(nutritionWidgetSize, 0.6, [
                    Color(0xFF97FF9A),
                    Color(0xFF66F86D),
                    Color(0xFF3DAF43),
                  ],Icons.fitness_center),
                  SizedBox(width: screenWidth * 0.05),
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

  Widget _buildMealSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          MealType.values.map((mealType) {
            final isSelected = mealType == selectedMeal;
            IconData icon;
            switch (mealType) {
              case MealType.breakfast:
                icon = Icons.free_breakfast;
                break;
              case MealType.lunch:
                icon = Icons.rice_bowl;
                break;
              case MealType.dinner:
                icon = Icons.dinner_dining;
                break;
              case MealType.snack:
                icon = Icons.local_pizza;
                break;
            }

            return GestureDetector(
              onTap: () => setState(() => selectedMeal = mealType),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange[200] : Colors.white,
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
                  icon,
                  color: isSelected ? Colors.deepOrange : Colors.grey,
                  size: 32,
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildActiveMealCard() {
    final meal = activeMeal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _mealTypeToString(meal.type),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            meal.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('P: ${meal.protein}g   C: ${meal.carbs}g   F: ${meal.fat}g'),
          const SizedBox(height: 8),
          Text('Calories: ${meal.calories} kcal'),
        ],
      ),
    );
  }

  String _mealTypeToString(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast 9:00 - 10:30';
      case MealType.lunch:
        return 'Lunch 12:00 - 14:00';
      case MealType.dinner:
        return 'Dinner 18:00 - 20:00';
      case MealType.snack:
        return 'Snack';
    }
  }

  Widget _buildNutritionRings(double ringSize, double percent, defaultColors, IconData icon) {
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
                    Icon(
                      icon,
                      size: ringSize * 0.15,
                      color: defaultColors[2],
                    ),
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
