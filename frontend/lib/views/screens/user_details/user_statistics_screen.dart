import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/blocs/user_details/user_statistics_bloc.dart';
import 'package:frontend/events/user_details/user_statistics_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/models/user_details/user_statistics.dart';
import 'package:frontend/models/user_details/user_weight_history.dart';
import 'package:frontend/states/user_statistics_states.dart';
import 'package:frontend/views/widgets/bottom_nav_bar.dart';
import 'package:frontend/views/widgets/error_message.dart';
import 'package:frontend/views/widgets/title_text.dart';
import 'package:frontend/views/widgets/weight_input_dialog.dart';
import 'package:go_router/go_router.dart';

class UserStatisticsScreen extends StatefulWidget {
  const UserStatisticsScreen({super.key});

  @override
  State<UserStatisticsScreen> createState() => _UserStatisticsScreenState();
}

class _UserStatisticsScreenState extends State<UserStatisticsScreen> {
  @override
  void initState() {
    super.initState();

    final bloc = context.read<UserStatisticsBloc>();
    bloc.add(LoadUserStatistics());

    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    bloc.add(LoadUserWeightHistory(start, now));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: TitleTextWidgets.scaledTitle(AppLocalizations.of(context)!.yourStatistics),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.monitor_weight_outlined),
                  label: Text(AppLocalizations.of(context)!.enterYourWeight),
                  onPressed: () async {
                    final saved = await WeightInputDialog.show(context);
                    if (saved == true && context.mounted) {
                      context.read<UserStatisticsBloc>().add(RefreshUserStatistics());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ---- RESZTA EKRANU ----
              Expanded(
                child: BlocBuilder<UserStatisticsBloc, UserStatisticsState>(
                  builder: (context, state) {
                    if (state.processingStatus.isOngoing) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.processingStatus.isFailure) {
                      return Center(
                        child: ErrorMessage(
                          message: state.getMessage != null
                              ? state.getMessage!(context)
                              : AppLocalizations.of(context)!.statisticsLoadFailure,
                        ),
                      );
                    }

                    final stats = state.statistics;
                    if (stats == null || stats.weeklyCaloriesConsumption.isEmpty) {
                      return Center(
                        child: Text(AppLocalizations.of(context)!.statistsMissing),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildChartCard(
                            title: AppLocalizations.of(context)!.calorieConsumptionChartTitle,
                            child: _buildCalorieChart(stats.weeklyCaloriesConsumption),
                          ),
                          _buildChartCard(
                            title: AppLocalizations.of(context)!.calorieGoalChartTitle,
                            child: _buildGoalComparisonChart(stats),
                          ),
                          const SizedBox(height: 16),
                          _buildChartCard(
                            title: AppLocalizations.of(context)!.weightChartTitle,
                            child: _buildWeightChart(state.weightHistory),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentRoute: GoRouterState.of(context).uri.path,
        mode: NavBarMode.normal,
      ),
    );
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(height: 220, child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieChart(List<DailyCaloriesStat> weeklyCaloriesConsumption) {
    final ordered = List<DailyCaloriesStat>.from(weeklyCaloriesConsumption)
      ..sort((a, b) => a.day.compareTo(b.day));
    final bars = ordered.map((e) => e.calories.toDouble()).toList();

    return BarChart(
      BarChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) {
                if (value == 0) return const Text('0');
                if (value >= 1000) return Text('${(value / 1000).toStringAsFixed(1)}k');
                return Text(value.toInt().toString());
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, _) {
                if (value < 0 || value >= bars.length) return const SizedBox();
                final day = ordered[value.toInt()].day;
                const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(labels[day.weekday - 1]),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: bars.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                color: Colors.orange,
                width: 18,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalComparisonChart(UserStatistics stats) {
    final ordered = List<DailyCaloriesStat>.from(stats.weeklyCaloriesConsumption)
      ..sort((a, b) => a.day.compareTo(b.day));
    final days = List<String>.generate(ordered.length, (i) {
      const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return labels[ordered[i].day.weekday - 1];
    });
    final spots = ordered
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.calories.toDouble()))
        .toList();

    final values = ordered.map((e) => e.calories).toList();
    final allValues = [...values, stats.targetCalories];

    if (allValues.isEmpty) return const SizedBox();

    final actualMin = allValues.reduce((a, b) => a < b ? a : b);
    final actualMax = allValues.reduce((a, b) => a > b ? a : b);

    double minY = (actualMin <= 300) ? 0 : (actualMin - 200).toDouble().clamp(0.0, double.infinity);
    double maxY = (actualMax + 200).toDouble();
    if (maxY - minY < 500) maxY = minY + 500;

    double interval = 100;
    final range = maxY - minY;

    if (range > 3000) {
      interval = 500.0;
    } else if (range > 1500) {
      interval = 250.0;
    } else if (range > 500) {
      interval = 100.0;
    } else {
      interval = 50.0;
    }

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i >= 0 && i < days.length) return Text(days[i], style: const TextStyle(fontSize: 10));
                return const SizedBox();
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              reservedSize: 40,
              getTitlesWidget: (value, _) {
                if (value >= 1000) return Text('${(value / 1000).toStringAsFixed(1)}K', style: const TextStyle(fontSize: 10));
                if (value.toInt() % interval.toInt() != 0) return const SizedBox();
                return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(days.length, (i) => FlSpot(i.toDouble(), stats.targetCalories.toDouble())),
            isCurved: false,
            color: Colors.green,
            barWidth: 2,
            dashArray: [5, 5],
            dotData: FlDotData(show: false),
          ),
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: Colors.orange.withAlpha(77)),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart(List<UserWeightHistory> history) {
    if (history.isEmpty) return const SizedBox();

    final ordered = List<UserWeightHistory>.from(history)
      ..sort((a, b) => a.day.compareTo(b.day));

    final spots = ordered
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.weightKg.toDouble()))
        .toList();

    final labels = ordered.map((e) => '${e.day.month}/${e.day.day}').toList();

    final minWeight = ordered.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b);
    final maxWeight = ordered.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minY: minWeight - 2,
        maxY: maxWeight + 2,
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) => Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox();
                return Text(labels[i], style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: Colors.orange.withAlpha(77)),
          ),
        ],
      ),
    );
  }
}
