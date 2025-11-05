import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/diet_generation/daily_summary_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/events/diet_generation/daily_summary_events.dart';
import 'package:frontend/foodini.dart';
import 'package:frontend/models/user/language.dart';
import 'package:frontend/states/diet_generation/daily_summary_states.dart';
import 'package:frontend/views/widgets/action_button.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid_value.dart';

class DailyMealsScreen extends StatelessWidget {
  final DateTime selectedDate;

  const DailyMealsScreen({super.key, required this.selectedDate});

  String formatForUrl(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final displayDate =
        "${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}";
    final prevDate = selectedDate.subtract(const Duration(days: 1));
    final nextDate = selectedDate.add(const Duration(days: 1));
    final prevRoute = '/daily-meals/${formatForUrl(prevDate)}';
    final nextRoute = '/daily-meals/${formatForUrl(nextDate)}';

    var state = context.watch<LanguageCubit>().state;
    var language = Language.fromJson(state.languageCode);

    return BlocProvider(
      key: ValueKey('bloc_${selectedDate}_${language.code}'),
      create: (context) => DailySummaryBloc(
        context.read(),
      )..add(GetDailySummary(selectedDate)),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<DailySummaryBloc, DailySummaryState>(
            builder: (context, state) {
              if (state is DailySummaryLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is DailySummaryError) {
                return Center(
                  child: Text(
                    state.message ?? 'Błąd ładowania danych',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                );
              }

              if (state is DailySummaryLoaded) {
                final meals = state.dailySummary.meals;
                final sortedEntries = meals.entries.toList()
                            ..sort((a, b) => a.key.value.compareTo(b.key.value));

                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          for (final entry in sortedEntries)
                            _buildMealSection(
                              title: AppConfig.mealTypeLabels(context)[entry.key]!,
                              color: _getMealColor(entry.key.name),
                              imageUrl: entry.value.iconPath!,
                              mealName: entry.value.name ?? '',
                              description: entry.value.description ?? '',
                              mealId: entry.value.mealId!,
                              context: context,
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                    _buildHeader(displayDate),
                    _buildBottomActionButton(context),
                  ],
                );
              }

              // Domyślny stan (np. Initial)
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          currentRoute: GoRouterState.of(context).uri.path,
          mode: NavBarMode.wizard,
          prevRoute: prevRoute,
          nextRoute: nextRoute,
        ),
      ),
    );
  }

  Widget _buildHeader(String displayDate) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
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
    );
  }

  Widget _buildBottomActionButton(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 8,
      child: Row(
        children: [
          ActionButton(
            onPressed: () {
              // TODO: logika regenerowania posiłków
            },
            color: const Color(0xFFF09090),
            label: 'Regenerate meals',
            keyId: 'generate_meals_button',
          ),
        ],
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
    required BuildContext context,
    required String title,
    required Color color,
    required String imageUrl,
    required String mealName,
    required String description,
    required UuidValue mealId,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.push('/meal-recipe/$mealId'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: '${Endpoints.mealIcon}/$imageUrl',
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
          ),
        ),
      ),
    );
  }
}
