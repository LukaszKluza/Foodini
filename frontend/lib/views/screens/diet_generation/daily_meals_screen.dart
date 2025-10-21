import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/constants.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

class DailyMealsScreen extends StatelessWidget {
  final DateTime selectedDate;

  const DailyMealsScreen({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Meals for $displayDate',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildMealSection(
                title: 'Breakfast',
                color: const Color(0xFFFFF0B3),
                imageUrl: 'https://via.placeholder.com/150',
                mealName: 'Oatmeal with fruits',
                description:
                    'A healthy oatmeal with banana and blueberries.',
              ),

              _buildMealSection(
                title: 'Lunch',
                color: const Color(0xFFC9EAB8),
                imageUrl: 'https://via.placeholder.com/150',
                mealName: 'Grilled chicken with rice',
                description:
                    'Tender chicken breast with steamed rice and salad.',
              ),

              _buildMealSection(
                title: 'Dinner',
                color: const Color(0xFFB6D8E7),
                imageUrl: 'https://via.placeholder.com/150',
                mealName: 'Vegetable soup',
                description: 'Warm and light vegetable soup to end the day.',
              ),

              const SizedBox(height: 24),
              _generateNewMealsButton(),
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
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

  Widget _generateNewMealsButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF2B2B2),
          minimumSize: const Size(double.infinity, Constants.buttonTextHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Generate new meals',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
