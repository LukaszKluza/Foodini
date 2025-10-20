import 'package:flutter/material.dart';
import 'package:frontend/states/diet_generation/meal_recipe.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

class MealDetailsScreen extends StatelessWidget {
  const MealDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _MealDetails(),
      bottomNavigationBar: BottomNavBar(
        currentRoute: GoRouterState.of(context).uri.path,
        mode: NavBarMode.wizard,
        prevRoute: '/diet-preferences',
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Macros Summary',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Carbs',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            '120g',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.bubble_chart, color: Colors.yellow[700]!),
                          SizedBox(height: 4),
                          Text(
                            'Fat',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            '60g',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.fitness_center, color: Colors.green),
                          SizedBox(height: 4),
                          Text(
                            'Protein',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            '90g',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.redAccent,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Calories',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            '1250 kcal',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Submit'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Skip Meal'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealDetails extends StatelessWidget {
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
              generateMealDetails(context), // Twój posiłek
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Padding generateMealDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          generateMealNameHeader(),
          // Meal summary box
          getExampleMeal(context),
          const SizedBox(height: 16),
          getExampleMeal(context),
          const SizedBox(height: 16),
          getExampleMeal(context),
          const SizedBox(height: 16),
          getExampleMeal(context),
          const SizedBox(height: 16),
          getExampleMeal(context),
          const SizedBox(height: 16),
          getExampleMeal(context),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      TextEditingController carbsController =
                          TextEditingController();
                      TextEditingController fatController =
                          TextEditingController();
                      TextEditingController proteinController =
                          TextEditingController();
                      TextEditingController nameController =
                          TextEditingController(text: 'Meal Name');

                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 12,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 500, // maksymalna szerokość dialogu
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Meal Name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: carbsController,
                                  decoration: InputDecoration(
                                    labelText: 'Carbs',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: fatController,
                                  decoration: InputDecoration(
                                    labelText: 'Fat',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: proteinController,
                                  decoration: InputDecoration(
                                    labelText: 'Protein',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                // Przyciski
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // akcja skanowania
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                      backgroundColor: Colors.orangeAccent,
                                    ),
                                    child: const Text('Scan product bar code'),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.grey[300],
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          backgroundColor: Colors.orangeAccent,
                                        ),
                                        child: const Text(
                                          'Save',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.orangeAccent,
                  elevation: 6,
                  shadowColor: Colors.orange.withAlpha(100),
                ),
                child: const Text(
                  'Add new meal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container getExampleMeal(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal name
          Text(
            'Meal Name',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),

          // Macros summary with icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: const [
                  Icon(Icons.local_fire_department, color: Colors.orange),
                  SizedBox(height: 4),
                  Text(
                    'Carbs',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text('40g', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.bubble_chart, color: Colors.yellow[700]!),
                  SizedBox(height: 4),
                  Text(
                    'Fat',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text('20g', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                children: const [
                  Icon(Icons.fitness_center, color: Colors.green),
                  SizedBox(height: 4),
                  Text(
                    'Protein',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text('30g', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                children: const [
                  Icon(Icons.local_fire_department, color: Colors.redAccent),
                  SizedBox(height: 4),
                  Text(
                    'Calories',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '1250 kcal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons in a row
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Edit meal popup
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[300],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Delete meal
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
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
}
