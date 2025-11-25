import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/diet_generation/daily_summary_bloc.dart';
import 'package:frontend/config/app_config.dart';
import 'package:frontend/config/custom_exception_code.dart';
import 'package:frontend/config/endpoints.dart';
import 'package:frontend/events/diet_generation/daily_summary_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/diet_generation/meal_type.dart';
import 'package:frontend/states/diet_generation/daily_summary_states.dart';
import 'package:frontend/utils/diet_generation/date_tools.dart';
import 'package:frontend/views/widgets/bottom_nav_bar_date.dart';
import 'package:frontend/views/widgets/error_message.dart';
import 'package:frontend/views/widgets/generate_meals_button.dart';
import 'package:frontend/views/widgets/title_text.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid_value.dart';

class DailyMealsScreen extends StatefulWidget {
  final DateTime selectedDate;

  DailyMealsScreen({Key? key, required this.selectedDate})
    : super(key: ValueKey('daily_meals_$selectedDate'));

  @override
  State<DailyMealsScreen> createState() => _DailyMealsScreenState();
}

class _DailyMealsScreenState extends State<DailyMealsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DailySummaryBloc>().add(GetDailySummary(widget.selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    final displayDate =
        "${widget.selectedDate.day.toString().padLeft(2, '0')}.${widget.selectedDate.month.toString().padLeft(2, '0')}.${widget.selectedDate.year}";

    final prevDate = widget.selectedDate.subtract(const Duration(days: 1));
    final nextDate = widget.selectedDate.add(const Duration(days: 1));

    final prevRoute = '/daily-meals/${formatForUrl(prevDate)}';
    final nextRoute = '/daily-meals/${formatForUrl(nextDate)}';

    final now = DateTime.now();
    final isToDay = isSameDay(now, widget.selectedDate);
    final isActiveDay = widget.selectedDate.isAfter(now) || isToDay;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<DailySummaryBloc, DailySummaryState>(
          builder: (context, state) {
            generateOnPressed() {
                context.read<DailySummaryBloc>().add(GenerateMealPlan(day: widget.selectedDate));
            }
            if (state.dietGeneratingInfo.processingStatus.isOngoing
                && state.dietGeneratingInfo.day != null
                && dateComparator(
                    state.dietGeneratingInfo.day!, widget.selectedDate) == 0) {
              return const Center(child: CircularProgressIndicator());
            } else if ((state.dietGeneratingInfo.processingStatus.isFailure &&
                (state.dietGeneratingInfo.day == null ||
                    dateComparator(state.dietGeneratingInfo.day!, widget.selectedDate) == 0)) ||
                state.gettingDailySummaryStatus.isFailure
            ) {
              final errorCode = state.errorCode;
              final errorData = state.errorData;
              final isMissingPredictions =
                  errorCode == 404 &&
                  errorData is Map &&
                  (errorData['code'] == CustomExceptionCode.missingDietPredictions.toJson());

              return Stack(
                children: [
                  Center(
                    child: ErrorMessage(
                      message: state.getMessage != null
                          ? state.getMessage!(context)
                          : AppLocalizations.of(context)!.unknownError,
                    ),
                  ),
                  if (isActiveDay && !isMissingPredictions)
                    DietGenerationInfoButton(
                      selectedDay: widget.selectedDate,
                      isRegenerateMode: false,
                      onPressed: generateOnPressed,
                    ),
                ],
              );
              }
            if (state.dailySummary != null &&
                dateComparator(state.dailySummary!.day, widget.selectedDate) == 0) {
              final meals = state.dailySummary!.meals;

              final bool isRegenerate = meals.isNotEmpty;
              final sortedEntries =
                  meals.entries.toList()
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
                            title:
                                AppConfig.mealTypeLabels(context)[entry.key]!,
                            color: _getMealColor(entry.key),
                            imageUrl: entry.value.iconPath!,
                            mealName: entry.value.name ?? '',
                            description: entry.value.description ?? '',
                            explanation: entry.value.explanation,
                            mealId: entry.value.mealId!,
                            context: context,
                          ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                  _buildHeader(displayDate),
                  if (widget.selectedDate.isAfter(now))
                    DietGenerationInfoButton(
                      selectedDay: widget.selectedDate,
                      isRegenerateMode: isRegenerate,
                      onPressed: generateOnPressed,
                      label: state.dailySummary!.isOutDated ?
                        AppLocalizations.of(context)!.dietOutdatedConsiderRegenerating :
                        AppLocalizations.of(context)!.regenerateMeals,
                    )
                  else if(isToDay && state.dailySummary!.isOutDated)
                    DietGenerationInfoButton(
                      selectedDay: widget.selectedDate,
                      isRegenerateMode: false,
                      label: AppLocalizations.of(context)!.dietOutdated
                    )
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
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

  Widget _buildHeader(String displayDate) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: TitleTextWidgets.scaledTitle(
              '${AppLocalizations.of(context)!.dailyMealsFor}$displayDate',
          ),
        ),
      ),
    );
  }

  Color _getMealColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return const Color(0xFFFFF0B3);
      case MealType.morningSnack:
        return const Color(0xFFDFB2C4);
      case MealType.lunch:
        return const Color(0xFFC9EAB8);
      case MealType.afternoonSnack:
        return const Color(0xFFCCBAAA);
      case MealType.dinner:
        return const Color(0xFFB6D8E7);
      case MealType.eveningSnack:
        return const Color(0xFFCBE3A8);
      }
  }
  void showInfoPopup(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFFFFF6E0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFFE68A00),
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Informacja',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.close,
                        size: 24,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealSection({
    required BuildContext context,
    required String title,
    required Color color,
    required String imageUrl,
    required String mealName,
    required String description,
    String? explanation,
    required UuidValue mealId,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.push('/meal-recipe/$mealId'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10,0,10,0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showInfoPopup(context, explanation!);
                        },
                        icon: const Icon(
                          Icons.info_outline,
                          size: 24,
                          color: Colors.black87,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: '${Endpoints.mealIcon}$imageUrl',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        memCacheWidth: 100,
                        memCacheHeight: 100,
                        placeholder:
                            (context, url) => const SizedBox(
                              width: 100,
                              height: 100,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
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
