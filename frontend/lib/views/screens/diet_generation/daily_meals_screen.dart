import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/diet_generation/meal.dart';
import 'package:frontend/views/widgets/action_button.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';


class DailyMealsScreen extends StatelessWidget {
  final DateTime selectedDate;

  const DailyMealsScreen({
    super.key,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    // Tymczasowa lista do testów
    final List<Meal> meals = [
      Meal(
        type: 'Breakfast',
        mealName: 'Oatmeal with fruits',
        description: 'A healthy oatmeal with banana and blueberries.',
        iconUrl: 'https://via.placeholder.com/150',
      ),
      Meal(
        type: 'Lunch',
        mealName: 'Grilled chicken with rice',
        description: 'Tender chicken breast with steamed rice and salad.',
        iconUrl: 'https://via.placeholder.com/150',
      ),
      Meal(
        type: 'Afternoon Snack',
        mealName: 'Vegetable soup',
        description: 'Warm and light vegetable soup to end the day.',
        iconUrl: 'https://via.placeholder.com/150',
      ),
      Meal(
        type: 'Dinner',
        mealName: 'Vegetable soup',
        description: 'Warm and light vegetable soup to end the day.',
        iconUrl: 'https://via.placeholder.com/150',
      ),
      Meal(
        type: 'Evening Snack',
        mealName: 'Vegetable soup',
        description: 'Warm and light vegetable soup to end the day.',
        iconUrl: 'https://via.placeholder.com/150',
      ),
    ];

    String formatForUrl(DateTime date) =>
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final displayDate =
        "${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}";

    final prevDate = selectedDate.subtract(const Duration(days: 1));
    final nextDate = selectedDate.add(const Duration(days: 1));
    final prevRoute = '/daily-meals/${formatForUrl(prevDate)}';
    final nextRoute = '/daily-meals/${formatForUrl(nextDate)}';

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  for (final meal in meals)
                    _buildMealSection(
                      title: meal.type,
                      color: _getMealColor(meal.type),
                      imageUrl: meal.iconUrl,
                      mealName: meal.mealName,
                      description: meal.description,
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical:12),
                child: Center(
                  child: Text(
                    'Meals for $displayDate',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 8,
              child: Row(
                children: [
                  ActionButton(
                    onPressed: () {
                      // TODO: logika generowania nowych posiłków
                    },
                    color: const Color(0xFFF09090),
                    label: 'Regenerate meals',
                    keyId: 'generate_meals_button',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentRoute: GoRouterState.of(context).uri.path,
        mode: NavBarMode.wizard,
        prevRoute: prevRoute,
        nextRoute: nextRoute,
      ),
    );
  }

  Color _getMealColor(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFFF0B3);
      case 'morning snack':
        return const Color(0xFFDFB2C4);
      case 'lunch':
        return const Color(0xFFC9EAB8);
      case 'afternoon snack':
        return const Color(0xFFCCBAAA);
      case 'dinner':
        return const Color(0xFFB6D8E7);
      case 'evening snack':
        return const Color(0xFFCBE3A8);
      default:
        return const Color(0xFFE0E0E0);
    }
  }

  Widget _buildMealSection({
    required String title,
    required Color color,
    required String imageUrl,
    required String mealName,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox(
                    width: 100,
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
