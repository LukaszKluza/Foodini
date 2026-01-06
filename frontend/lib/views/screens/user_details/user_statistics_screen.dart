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
import 'package:frontend/views/widgets/diet_generation/action_buttons.dart';
import 'package:frontend/views/widgets/error_message.dart';
import 'package:frontend/views/widgets/title_text.dart';
import 'package:frontend/views/widgets/user_details/weight_input_dialog.dart';
import 'package:go_router/go_router.dart';

class UserStatisticsScreen extends StatefulWidget {
  const UserStatisticsScreen({super.key});

  @override
  State<UserStatisticsScreen> createState() => _UserStatisticsScreenState();
}

class _UserStatisticsScreenState extends State<UserStatisticsScreen> {
  late final UserStatisticsBloc statisticsBloc;
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();

    statisticsBloc = context.read<UserStatisticsBloc>();
    endDate = DateTime.now();
    startDate = endDate.subtract(const Duration(days: 30));

    statisticsBloc.add(LoadUserStatistics());
    statisticsBloc.add(LoadUserWeightHistory(startDate, endDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Scaffold(
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
                      child: customCenterButton(
                        const Key('add_weight_button'),
                        () async {
                          await WeightInputDialog.show(context, startDate, endDate);
                        },
                        ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size.fromHeight(48),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.monitor_weight_outlined,
                              size: 40,
                            ),
                            const SizedBox(width: 10),
                            Text(AppLocalizations.of(context)!.enterYourWeight),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

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
          ),
        ),
      )
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

  Widget _buildGoalComparisonChart(UserStatistics stats) {
    final ordered = List<DailyCaloriesStat>.from(stats.weeklyCaloriesConsumption)
      ..sort((a, b) => a.day.compareTo(b.day));
    final days = List<String>.generate(ordered.length, (i) {
      final labels = [
        AppLocalizations.of(context)!.mon,
        AppLocalizations.of(context)!.tue,
        AppLocalizations.of(context)!.wed,
        AppLocalizations.of(context)!.thu,
        AppLocalizations.of(context)!.fri,
        AppLocalizations.of(context)!.sat,
        AppLocalizations.of(context)!.sun,
      ];
      return labels[ordered[i].day.weekday - 1];
    });
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

    return BarChart(
      BarChartData(
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
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: stats.targetCalories.toDouble(),
              color: Colors.green,
              strokeWidth: 2,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                labelResolver: (line) => line.y.toString(),
              ),
            ),
          ],
        ),
        barGroups: List.generate(values.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i].toDouble(),
                color: Colors.orange,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        })
      ),
    );
  }

  Widget _buildWeightChart(List<UserWeightHistory> history) {
    final loc = AppLocalizations.of(context)!;

    if (history.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48, color: Colors.grey.withAlpha(120)),
            const SizedBox(height: 12),
            Text(
              loc.noWeightDataAvailable,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final ordered = List<UserWeightHistory>.from(history)
      ..sort((a, b) => a.day.compareTo(b.day));

    final spots = ordered
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.weightKg.toDouble()))
        .toList();

    final labels = ordered.map((e) => '${e.day.day}/${e.day.month}').toList();

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
