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
  const DailySummaryScreen({Key? key}) : super(key: key);

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
              _buildCaloriesSummary(),

              const SizedBox(height: 16),

              _buildMealSelector(),

              const SizedBox(height: 16),

              _buildActiveMealCard(),

              const SizedBox(height: 16),

              _buildNutritionRings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$eatenCalories / $dailyGoal',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.circle, color: Colors.grey[400], size: 16),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildNutritionRings() {
    return Center(
      child: CircularPercentIndicator(
        radius: 120,
        lineWidth: 14,
        animation: true,
        percent: eatenCalories / dailyGoal,
        center: const Icon(Icons.track_changes, size: 50, color: Colors.white),
        backgroundColor: Colors.grey[300]!,
        progressColor: Colors.deepOrangeAccent,
        circularStrokeCap: CircularStrokeCap.round,
        footer: const Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Daily Progress',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
