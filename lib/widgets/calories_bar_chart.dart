import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:bwthw_project/theme.dart';

class CalorieData {
  final String label;
  final double value;
  CalorieData(this.label, this.value);
}

//used for displaying calorie consumption trend in DataPage
class CaloriesBarChart extends StatelessWidget {
  final List<CalorieData> data;

  const CaloriesBarChart({super.key, required this.data});

  double _maxY() {
    if (data.isEmpty) return 0;
    return data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  }

  double _safeInterval(double maxValue) {
    if (maxValue <= 0 || maxValue.isNaN || maxValue.isInfinite) return 500;
    final base = maxValue / 4;
    const magnitude = 500.0;
    final normalized = (base / magnitude).ceil() * magnitude;
    return normalized < magnitude ? magnitude : normalized;
  }

  @override
  Widget build(BuildContext context) {
    final maxValue = _maxY();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(20),
      height: 280,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY CALORIES BURNED',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxValue > 0 ? maxValue + 500 : 2500,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.outline,
                    strokeWidth: 1,
                    dashArray: [4, 6],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= data.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            data[i].label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _safeInterval(maxValue),
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.muted,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(data.length, (i) {
                  final value = data[i].value;
                  final isMax = value == maxValue && maxValue > 0;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        width: 16,
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: isMax
                              ? [AppColors.fat, const Color(0xFFFFD466)]
                              : [
                                  AppColors.fat.withValues(alpha: 0.3),
                                  AppColors.fat.withValues(alpha: 0.6),
                                ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
